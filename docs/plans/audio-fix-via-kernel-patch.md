# Audio Fix via Kernel Patch — Lenovo Yoga S940-14IWL

Status: **investigated, not implemented**. This documents the diagnosis and a
concrete plan for a proper fix. The immediate "no sound" issue is fixed; the
"tinny sound" issue remains open and requires a kernel patch.

## Problem statement

On the Debian host (Lenovo Yoga S940-14IWL), audio was completely dead, then —
after installing missing firmware — working but thin/tinny (weak bass), with
noticeably better sound under Windows on the same hardware. The tinny character
reproduced across every Linux distribution tried.

## Hardware

| Component | Value |
|-----------|-------|
| Machine | Lenovo Yoga S940-14IWL (`LENOVO-81Q7`, DMI `LNVNB161216`) |
| Audio controller | Intel Cannon Point-LP HDA (`PCI 00:1f.3`, `8086:9dc8`) |
| Codec | Realtek ALC298 (`0x10ec0298`) |
| Codec SSID | `0x17aa3816` |
| Driver | SOF (`sof-hda-dsp` / `snd_soc_skl_hda_dsp`), **not** `snd-hda-intel` |
| Topology | `skl_hda_dsp_generic` |
| Speakers | 4-driver array (2 tweeters + 2 woofers) |
| Stack | PipeWire 1.6.8 + WirePlumber |

## Two distinct problems

### 1. No sound (fixed)

Root cause: the SOF driver could not bind because the SOF firmware was missing.

- `/lib/firmware/intel/sof/` and `/lib/firmware/intel/sof-tplg/` did not exist.
- `firmware-sof-signed` was not installed.
- Symptom: `aplay -l` → `no soundcards found`; `/proc/asound/cards` empty;
  PipeWire showed only "Dummy Output".

Fix (already applied):

```bash
sudo apt install firmware-sof-signed firmware-intel-sound
sudo reboot
```

### 2. Tinny sound (open)

Root cause: the woofer channel is not driven, and the codec's built-in DSP is
left at factory defaults.

Codec node topology (from `/proc/asound/card0/codec#0`):

| Node | Type | Role | Pin default | State |
|------|------|------|-------------|-------|
| `0x02` | Audio Output | headphone DAC | — | active |
| `0x03` | Audio Output | speaker DAC (has amp) | — | active |
| `0x06` | Audio Output | DAC3 (no amp-out) | — | idle |
| `0x14` | Pin Complex | Speaker (tweeter) | `0x90170140` (Fixed/Internal/Speaker) | enabled, routed via `0x0d`→`0x03` |
| `0x17` | Pin Complex | Speaker (woofer) | `0x411111f0` (N/A) | disabled; conns `0x0c* 0x0d 0x06` |
| `0x1e` | Pin Complex | extra output | `0x411111f0` (N/A) | disabled; conns `0x06` only |
| `0x20` | Processing | DSP (150 coefficients) | — | factory defaults |

Key points:

- The woofer is on pin `0x17`, which the BIOS marks N/A, so the Linux parser
  never enables it. Windows' Realtek driver overrides the BIOS.
- `0x06` (DAC3) has no amp-out capability. On this codec family the speaker can
  be mis-routed through `0x06`, making it silent/unadjustable.
- `0x20` is the codec's built-in DSP/crossover that Windows programs with
  proprietary coefficients; Linux leaves it untouched.

## Investigation experiments already performed

1. **Bass Speaker re-pin (no audible change).** Overriding pin `0x17` to
   `0x90170141` via an early-patch firmware file did make a `Bass Speaker`
   mixer control appear, but produced no audible change. Likely cause: the
   parser still routed `0x17` through amp-less DAC3 (`0x06`), so the woofer
   never actually produced signal. Since reverted.

2. **Early-patch mechanism notes.** On SOF the patch firmware is loaded by
   `snd_soc_hdac_hda` (module param `patch`, array indexed by codec address),
   **not** `snd-hda-intel`. This is why `hdajackretask`'s "Install boot
   override" (`options snd-hda-intel patch=...`) silently did nothing here. A
   plain-text patch file at `/lib/firmware/hda-jack-retask.fw` with a matching
   `options snd_soc_hdac_hda patch=hda-jack-retask.fw` does load.

## Research findings

Searching for the codec SSID (`0x17aa3816`) found no existing quirk or dump.
However, kernel source (`sound/hda/codecs/realtek/alc269.c`, formerly
`patch_realtek.c`) contains two highly relevant neighbours:

- **Lenovo C940 / Yoga Duet 7** (`0x17aa:0x3818`, same ALC298):
  `ALC298_FIXUP_LENOVO_C940_DUET7` → `ALC298_FIXUP_LENOVO_SPK_VOLUME` →
  `alc298_fixup_speaker_volume()`. Its comment confirms the routing bug:

  > The speaker is routed to the Node 0x06 by a mistake ... we change the
  > speaker's route to: Node 0x02 → Node 0x0c → Node 0x17, since Node 0x02 has
  > Amp-out caps.

  Implementation: `snd_hda_override_conn_list(codec, 0x17, 1, {0x0c})`.

- **Razer Blade 16 2025** (`ALC298`): re-pins the exact same two nodes and
  ships a full DSP coefficient dump:
  ```c
  { 0x14, 0x90170121 }, /* tweeter as internal speaker, seq 1 */
  { 0x17, 0x90170120 }, /* woofer  as internal speaker, seq 0 */
  ```
  with the coefficient data in `sound/hda/helpers/razer_blade16_2025.c`.

Conclusion: the topology is understood and precedented, but **no fix exists yet
for the S940 specifically** (`0x3816` is unquirked).

## Proposed fix

Add a new fixup keyed to `0x17aa:0x3816`, modeled on the C940 + Razer fixes:

1. **Re-pin** `0x17` as an internal speaker (woofer), e.g. `0x90170120`, so the
   parser exposes it as `Bass Speaker`.
2. **Re-route** `0x17` off amp-less DAC3 so it shares the speaker DAC with the
   tweeter (i.e. `snd_hda_override_conn_list`), mirroring
   `alc298_fixup_speaker_volume` / `alc285_fixup_speaker2_to_dac1`.
3. **Optional:** program DSP coefficients on node `0x20` for the crossover/EQ.
   This requires the proprietary coefficients (see below) and is the part that
   actually matches Windows' sound quality; the re-pin + re-route alone should
   restore missing bass but not full tuning.

Rough patch shape (against `sound/hda/codecs/realtek/alc269.c`):

```c
/* pins */
{ 0x17, 0x90170120 }, /* woofer */

/* func fixup */
static void alc298_fixup_yoga_s940(struct hda_codec *codec, ...) {
    static const hda_nid_t conn[] = { 0x0d }; /* share speaker DAC w/ tweeter */
    snd_hda_override_conn_list(codec, 0x17, ARRAY_SIZE(conn), conn);
}
```

plus a `SND_PCI_QUIRK(0x17aa, 0x3816, "Lenovo Yoga S940-14IWL",
ALC298_FIXUP_YOGA_S940)` entry.

## Delivery & testing

Two delivery options, in order of preference:

1. **DKMS rebuild of the codec module only** (recommended, low risk):
   rebuild `snd-hda-codec-realtek` against the running kernel, install via DKMS,
   rebuild initramfs, reboot.
2. **Full custom kernel**: safe as long as the current kernel is kept as a
   separate GRUB entry and never overwritten.

Test plan: verify `Bass Speaker` control appears *and* the woofer is audible
(play a bass-heavy track, compare against current tinny baseline). Confirm
headphone auto-mute and mic still work.

## Risk & recovery

- The codec-module change cannot prevent boot. Worst case is a module that fails
  to load → no sound (the pre-fix state). A panic on load can be bypassed with
  `modprobe.blacklist=snd_hda_codec_realtek`.
- Revert = remove the DKMS module, rebuild initramfs, reboot.
- The Arch host on the same machine is a valid recovery path: boot Arch, mount
  the Debian root, `chroot`, and revert (remove DKMS module / reinstall distro
  kernel / `update-initramfs` / `grub-mkconfig`).
- Caveat: do not clobber the shared EFI System Partition from the Debian side.

## Alternatives considered

| Option | Verdict |
|--------|---------|
| EasyEffects parametric EQ | Tried on Arch host; only marginal improvement. EQ approximates but cannot replace the missing DSP crossover. |
| Windows To Go (USB) verb dump | Cleanest way to capture the proprietary DSP coefficients; runs Windows on hardware without touching GRUB/internal disk. Enables option 3 of the fix. |
| Windows VM with VFIO passthrough | **Blocked.** Audio controller (`00:1f.3`) shares IOMMU group 12 with the ISA bridge, SMBus, and SPI (`00:1f.0/.4/.5`); clean passthrough impossible, ACS-override unsafe. Also re-binding resets the codec, wiping coefficients. |
| Bare-metal Windows dual boot | User declined (GRUB concerns); Windows To Go sidesteps this. |

## References

- Kernel early-patching docs: `Documentation/sound/hd-audio/notes.rst`
  (`[codec]`/`[pincfg]`/`[verb]`/`[hint]` format, `patch=` module param).
- `sound/hda/codecs/realtek/alc269.c` — `alc298_fixup_speaker_volume`,
  `ALC298_FIXUP_LENOVO_C940_DUET7`, Razer Blade 16 pin fixup.
- SOF patch loader: `sound/soc/codecs/hdac_hda.c`
  (`module_param_array_named(patch, ...)`).
- Lenovo Yoga C930 reference fix (same ALC298 class):
  `github.com/droserasprout/lenovo-yoga-c930-linux` (pin `0x17` override).
