# Common tree for Meizu MediaTek devices (LineageOS 20.0)

Shared by the Meizu MX6 (`m95`, MT6797), M5c (`m5c`, MT6737M) and M3 Note (`m3note`, MT6755) device trees.
It goes to `device/meizu/common` through the local manifests in
[android_local_manifests_meizu](https://github.com/nomorecoolnicknames/android_local_manifests_meizu).

## Platform patches

These devices run Nougat-era MediaTek vendor blobs on 3.18 and 4.9 kernels. A few things they need can only be
changed in the LineageOS platform itself. Those changes are kept as patches in `patches/<project path>/`.

`vendorsetup.sh` applies them when `build/envsetup.sh` is sourced, so the usual `breakfast` / `brunch` needs
nothing extra. A patch that is already in a project (same Change-Id, or the same change) is skipped, so
sourcing `envsetup.sh` again or after `repo sync` is safe. If a patch does not apply, the script prints the
patch and the project, leaves that project unchanged and goes on with the others; `repo sync -d <project>`
returns the project to the manifest revision.

| Project | Patches |
| --- | --- |
| `bionic` | null printf format from legacy vendor code |
| `frameworks/av` | vendor copy of `libcamera_client` for Nougat camera HALs, Marshmallow `getCameraInfo()` |
| `frameworks/base` | VINTF kernel check on legacy kernels; backported SystemUI and HWUI crash fixes |
| `frameworks/opt/telephony` | legacy MediaTek RIL: carrier privilege timeout, baseband property length, `setDataProfile` on IRadio < 1.4, `PhoneSwitcher` notification |
| `hardware/interfaces` | Nougat audio HAL ABI, legacy camera module claims and fixes, GNSS NMEA, consumer IR, HWC1 client target fence |
| `packages/modules/Bluetooth` | controllers that fail a later extended-features page |
| `system/core` | cgroup v1 fallback, f2fs on kernels without feature flags, literal socket names, `Thread::run` for vendor code |
| `system/linkerconfig` | sphal links for legacy Mali drivers |
| `system/netd` | kernels without `xt_bpf` revision 1 |

Each patch says in its message what it changes and why. Changes that only one of the devices needs are gated by
device properties or by what the kernel and the blobs provide.
