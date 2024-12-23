extends Node


## -----------------------------------------------------------------------------


# The amount of padding that the texture should have around its edges to allow
# for the selection shader to show an outline around the token. This is the
# total number of empty pixekls along each of the 4 edges of the token.
var token_padding := 16


# A map that we use to track which textures we've previously padded out, so that
# we do not need to pad them a second time.
#
# In the dictionary, the key is a unique RID of a texture which has previously
# been padded, and the value is the newly constructed texture that was padded
# out for that token.
var _texture_map = {}


## -----------------------------------------------------------------------------



# This takes an input texture and creates a new version of it that is grown in
# all four directions based on the padding set in the node. The new texture is
# first filled with transparency and then the original texture is drawn into it
# offset by the padding distance.
#
# This causes the token texture to be surrounded by alpha, which allows our
# shader to show an activation rectangle around it.
func alpha_pad(in_texture: Texture2D) -> Texture2D:
    # Don't pad textures if we didn't get one to pad.
    if in_texture == null:
        return in_texture

    # If this texture has previously been badded, then we can return the
    # new texture back directly; otherwise we need to do some padding work.
    var cached_texture = _texture_map.get(in_texture.get_rid())
    if cached_texture != null:
        print_verbose("Alpha Padding Cache HIT: %s" % in_texture.resource_path)
        return cached_texture

    print_verbose("Alpha Padding Texture: %s (%s)" % [in_texture.resource_path, in_texture.get_rid()])

    # Capture the padding as a vector for later.
    var padding = Vector2(token_padding, token_padding)

    # Get the image that backs the texture as well as its size. Note that this
    # does a fetch from the graphics card, so it is costly to do it frequently.
    var image = in_texture.get_image()
    var img_size = image.get_size()

    # We require our textures to have transparency, since that is the whole
    # point of what we're doing. If there is not any alpha, convert the souirce.
    if image.detect_alpha() == Image.AlphaMode.ALPHA_NONE:
        #print("token texture has no transparency (format=%s); converting" % image.get_format())
        image.convert(Image.Format.FORMAT_RGBA8)

    # Create the destination image, which should be bigger than the original
    # in both directions based on the padding.
    # 2. Create a new image that is bigger than the input texture, with padding
    var new_image = Image.create_empty(
        img_size.x + (2 * padding.x),
        img_size.y + (2 * padding.y),
        true, image.get_format())
    new_image.fill(Color(Color.WHITE, 0.0))

    # Draw into the new image the original image from the texture, with a
    # padding offset on the upper left so that we get the appropriate padding.
    var src_rect = Rect2(Vector2(0, 0), img_size)
    new_image.blit_rect(image, src_rect, padding)

    # Create the new texture from the image, then cache it for next time.
    var new_texture := ImageTexture.create_from_image(new_image)
    _texture_map[in_texture.get_rid()] = new_texture

    # We can return the new result now.
    return new_texture



## -----------------------------------------------------------------------------
