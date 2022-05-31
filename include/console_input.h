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
	
    console_input()
    {
        valid_input = false;
    }


    //-----------------------------------------------------------------------------
    //void set_running(bool v) { running = v; }

    bool get_running() { return running; }


    //-----------------------------------------------------------------------------
    bool get_valid_input(void) { return valid_input; }

    void reset_valid_input(void)
    {
        valid_input = false;
    }

    unsigned char get_input(void) { return ch2; }

    //-----------------------------------------------------------------------------
    void arrow_key(void)
    {
        running = true;
        valid_input = false; 
        run_thread = std::thread(&console_input::run_arrow_key, this);
    }

    //-----------------------------------------------------------------------------
    inline void run_arrow_key(void)
    {
        while (running)
        {
            std::this_thread::sleep_for(std::chrono::milliseconds(20));
     
            unsigned char ch1 = _getch();
            if ((ch1 == KEY_ARROW_CHAR1) || (ch1 == 0))
            {
                // Some Arrow key was pressed, determine which?
                ch2 = _getch();
                //switch (ch2)
                //{
                //case KEY_ARROW_UP:
                //    // code for arrow up
                //    std::cout << "KEY_ARROW_UP" << std::endl;
                //    break;
                //case KEY_ARROW_DOWN:
                //    // code for arrow down
                //    std::cout << "KEY_ARROW_DOWN" << std::endl;
                //    break;
                //case KEY_ARROW_LEFT:
                //    // code for arrow right
                //    std::cout << "KEY_ARROW_LEFT" << std::endl;
                //    break;
                //case KEY_ARROW_RIGHT:
                //    // code for arrow left
                //    std::cout << "KEY_ARROW_RIGHT" << std::endl;
                //    break;
                //}

                valid_input = true;
            }
            else if (ch1 == 27)
            {
                running = false;
                valid_input = false;
            }
        }

        run_thread.join();
    }   // end of run

    void stop(void)
    {
        running = false;
        run_thread.join();
    }

//-----------------------------------------------------------------------------
private:
    static const int KEY_ARROW_CHAR1 = 224;
    //static const int KEY_ARROW_UP = 72;
    //static const int KEY_ARROW_DOWN = 80;
    //static const int KEY_ARROW_LEFT = 75;
    //static const int KEY_ARROW_RIGHT = 77;

	bool valid_input;
    bool running;

    std::thread run_thread;

    unsigned char ch2;

};  // end of class

#endif  // CONSOLE_INPUT_CLASS_H_
