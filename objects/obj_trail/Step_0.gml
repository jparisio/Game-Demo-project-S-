//image_alpha -= 0.04
TweenEasyFade(image_alpha, 0, 0, 4, EaseInSine)
if image_alpha <= 0 instance_destroy();