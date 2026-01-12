from PIL import Image

def resize_with_padding(input_path, output_path, scale_factor=3):
    img = Image.open(input_path)
    # Original size
    width, height = img.size
    
    # New icon size (1/3)
    new_width = int(width / scale_factor)
    new_height = int(height / scale_factor)
    
    # Resize the icon relative to original
    img_small = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    
    # Create a new blank image with the same original size (transparent)
    new_img = Image.new("RGBA", (width, height), (0, 0, 0, 0))
    
    # Paste the small icon in the center
    paste_x = (width - new_width) // 2
    paste_y = (height - new_height) // 2
    new_img.paste(img_small, (paste_x, paste_y))
    
    new_img.save(output_path)
    print(f"Created {output_path} with 1/{scale_factor} scale")

resize_with_padding("assets/icon/icon.png", "assets/icon/splash_icon_padded.png", scale_factor=3)
