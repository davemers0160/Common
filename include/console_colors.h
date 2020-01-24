#ifndef _CONSOLE_COLORS_H_
#define _CONSOLE_COLORS_H_

#include <string>

const std::string esc("\x1b");
const std::string csi("\x1b[");

const std::string black("0");
const std::string red("1");
const std::string green("2");
const std::string yellow("3");
const std::string blue("4");
const std::string magenta("5");
const std::string cyan("6");
const std::string white("7");

const std::string reset("\x1b[0m");

// ----------------------------------------------------------------------------------------
inline std::string def_color(const std::string& fg)
{
    return (csi + "0;3" + fg + "m");
}

// ----------------------------------------------------------------------------------------
inline std::string color(const std::string& fg, const std::string& bg)
{
    return (csi + "4" + bg + ";3" + fg + "m");
}

// ----------------------------------------------------------------------------------------
inline std::string bright_color(const std::string& fg, const std::string& bg)
{
    return (csi + "10" + bg + ";9" + fg + "m");
}

#endif  // _CONSOLE_COLORS_H_

