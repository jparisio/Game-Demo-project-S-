/// Return: Floating point number interpolated from <start> to <end> using the give animation curve as the lerping factor
/// 
/// @param start      Starting value
/// @param end        End value
/// @param animCurve  Animation curve to use
/// @param posx       x-position to read from

function AnimcurveTween(_start, _end, _curve, _t)
{
    var _w = animcurve_channel_evaluate(animcurve_get_channel(_curve, 0), _t);
    var _value = lerp(_start, _end, _w);
    return _value;
}