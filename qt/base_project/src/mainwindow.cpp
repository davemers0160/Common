#pragma once

#include <cmath>
#include <filesystem>
#include <fstream>
#include <chrono>

#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QProgressDialog>
#include <QActionGroup>
#include <QVector>
#include <QThread>
#include <QWidgetAction>


//-----------------------------------------------------------------------------
void debug_console()
{

#if defined(_WIN32) | defined(__WIN32__) | defined(__WIN32) | defined(_WIN64) | defined(__WIN64)
    AllocConsole();
    FILE* pFileCon = NULL;
    pFileCon = freopen("CONOUT$", "w", stdout);

    COORD coordInfo;
    coordInfo.X = 130;
    coordInfo.Y = 9000;

    SetConsoleScreenBufferSize(GetStdHandle(STD_OUTPUT_HANDLE), coordInfo);
    SetConsoleMode(GetStdHandle(STD_OUTPUT_HANDLE), ENABLE_QUICK_EDIT_MODE | ENABLE_EXTENDED_FLAGS);
#endif

}

//-----------------------------------------------------------------------------
// Constructor
MainWindow::MainWindow(QWidget* parent)
    : QMainWindow(parent), 
    gui(new gui_::MainWindow)
{

    gui->setupUi(this);
    
//    this->connect(gui->action_XXXX, SIGNAL(triggered()), this, SLOT(on_action_Image_Directory_Location()));

    // DEBUG
    int bp = 0;

}   // end of MainWindow

//-----------------------------------------------------------------------------
// Destructor
MainWindow::~MainWindow()
{
    delete gui;
}


