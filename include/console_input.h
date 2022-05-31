#ifndef CONSOLE_INPUT_CLASS_H_
#define CONSOLE_INPUT_CLASS_H_

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)

#include <conio.h>

#elif defined(__linux__)

#endif

#include <cstdint>
#include <thread>
#include <iostream>


//-----------------------------------------------------------------------------
class console_input
{
public:
	
    bool running = true;

	console_input() = default;

	//console_input(bool r_) : running(r_) {}


    //-----------------------------------------------------------------------------
    bool get_valid_input(void) { return valid_input; }

    void reset_valid_input(void)
    {
        valid_input = false;
    }

    //-----------------------------------------------------------------------------
    //void run_t(void)
    //{
    //    std::thread run_thread(&console_input::run, this);

    //    run_thread.join();
    //}

    //-----------------------------------------------------------------------------
    inline void run(void)
    {
        while (running)
        {
            unsigned char ch1 = _getch();
            if ((ch1 == KEY_ARROW_CHAR1) || (ch1 == 0))
            {
                // Some Arrow key was pressed, determine which?
                unsigned char ch2 = _getch();
                switch (ch2)
                {
                case KEY_ARROW_UP:
                    // code for arrow up
                    cout << "KEY_ARROW_UP" << endl;
                    break;
                case KEY_ARROW_DOWN:
                    // code for arrow down
                    cout << "KEY_ARROW_DOWN" << endl;
                    break;
                case KEY_ARROW_LEFT:
                    // code for arrow right
                    cout << "KEY_ARROW_LEFT" << endl;
                    break;
                case KEY_ARROW_RIGHT:
                    // code for arrow left
                    cout << "KEY_ARROW_RIGHT" << endl;
                    break;
                }

                valid_input = false;
            }
        }
    }   // end of run


//-----------------------------------------------------------------------------
private:
    static const int KEY_ARROW_CHAR1 = 224;
    static const int KEY_ARROW_UP = 72;
    static const int KEY_ARROW_DOWN = 80;
    static const int KEY_ARROW_LEFT = 75;
    static const int KEY_ARROW_RIGHT = 77;

	bool valid_input;


};  // end of class

#endif  // CONSOLE_INPUT_CLASS_H_
