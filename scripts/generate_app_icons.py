#!/usr/bin/env python3
from pathlib import Path

from PIL import Image

SRC = Path('assets/icon/calora_logo.png')
BG = (0xF3, 0xE8, 0xCC, 255)


def make_icon(size: int, pad_ratio: float = 0.14) -> Image.Image:
    logo = Image.open(SRC).convert('RGBA')
    canvas = Image.new('RGBA', (size, size), BG)
    inner = int(size * (1 - 2 * pad_ratio))
    logo_fitted = logo.copy()
    logo_fitted.thumbnail((inner, inner), Image.Resampling.LANCZOS)
    x = (size - logo_fitted.width) // 2
    y = (size - logo_fitted.height) // 2
    canvas.alpha_composite(logo_fitted, (x, y))
    return canvas


def make_adaptive_foreground(size: int) -> Image.Image:
    logo = Image.open(SRC).convert('RGBA')
    canvas = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    inner = int(size * 0.66)
    logo_fitted = logo.copy()
    logo_fitted.thumbnail((inner, inner), Image.Resampling.LANCZOS)
    x = (size - logo_fitted.width) // 2
    y = (size - logo_fitted.height) // 2
    canvas.alpha_composite(logo_fitted, (x, y))
    return canvas


def save_png(path: Path, image: Image.Image) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    image.save(path, format='PNG')
    print('wrote', path)


def main() -> None:
    save_png(Path('assets/icon/app_icon.png'), make_icon(1024, 0.12))

    android_sizes = {
        'mipmap-mdpi': 48,
        'mipmap-hdpi': 72,
        'mipmap-xhdpi': 96,
        'mipmap-xxhdpi': 144,
        'mipmap-xxxhdpi': 192,
    }
    for folder, size in android_sizes.items():
        save_png(Path(f'android/app/src/main/res/{folder}/ic_launcher.png'), make_icon(size))
        save_png(
            Path(f'android/app/src/main/res/{folder}/ic_launcher_foreground.png'),
            make_adaptive_foreground(size),
        )

    save_png(
        Path('android/app/src/main/res/drawable/ic_launcher_foreground.png'),
        make_adaptive_foreground(432),
    )

    ios_dir = Path('ios/Runner/Assets.xcassets/AppIcon.appiconset')
    for name, size in [
        ('Icon-App-20x20@1x.png', 20),
        ('Icon-App-20x20@2x.png', 40),
        ('Icon-App-20x20@3x.png', 60),
        ('Icon-App-29x29@1x.png', 29),
        ('Icon-App-29x29@2x.png', 58),
        ('Icon-App-29x29@3x.png', 87),
        ('Icon-App-40x40@1x.png', 40),
        ('Icon-App-40x40@2x.png', 80),
        ('Icon-App-40x40@3x.png', 120),
        ('Icon-App-60x60@2x.png', 120),
        ('Icon-App-60x60@3x.png', 180),
        ('Icon-App-76x76@1x.png', 76),
        ('Icon-App-76x76@2x.png', 152),
        ('Icon-App-83.5x83.5@2x.png', 167),
        ('Icon-App-1024x1024@1x.png', 1024),
    ]:
        save_png(ios_dir / name, make_icon(size).convert('RGB'))

    mac_dir = Path('macos/Runner/Assets.xcassets/AppIcon.appiconset')
    for size in [16, 32, 64, 128, 256, 512, 1024]:
        save_png(mac_dir / f'app_icon_{size}.png', make_icon(size).convert('RGB'))

    web_dir = Path('web/icons')
    for size, name in [(192, 'Icon-192.png'), (512, 'Icon-512.png')]:
        save_png(web_dir / name, make_icon(size))
    for size, name in [(192, 'Icon-maskable-192.png'), (512, 'Icon-maskable-512.png')]:
        save_png(web_dir / name, make_icon(size, pad_ratio=0.2))
    save_png(Path('web/favicon.png'), make_icon(32).convert('RGB'))

    ico_sizes = [16, 32, 48, 64, 128, 256]
    images = [make_icon(s).convert('RGBA') for s in ico_sizes]
    images[0].save(
        'windows/runner/resources/app_icon.ico',
        format='ICO',
        sizes=[(s, s) for s in ico_sizes],
        append_images=images[1:],
    )
    print('wrote windows/runner/resources/app_icon.ico')


if __name__ == '__main__':
    main()
