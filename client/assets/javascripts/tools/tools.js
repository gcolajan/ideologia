/**
 * Convert the health [0f;1f] to a Color (RGB) (red->yellow->green)
 * @param percentage
 * @constructor
 */
function Health2Color(percentage)
{
    var color = new Color();
    if (percentage < 0 || percentage > 1)
        return color;

    color.blue = 0;

    if (percentage > 0.5)
    {
        color.red = Math.floor((1 - ((percentage - 0.5) * 2)) * 255);
        color.green = 255;
    }
    else
    {
        color.red = 255;
        color.green = Math.floor((percentage * 2) * 255);
    }

    return color;
}