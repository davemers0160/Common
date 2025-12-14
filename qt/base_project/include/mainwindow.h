#pragma once

#include <ryml_all.hpp>
#include <cstdint>
#include <vector>
#include <string>

#include <QMainWindow>
#include <QMessageBox>
#include <QFileDialog>
#include <QModelIndex>

// custom includes


QT_BEGIN_NAMESPACE
namespace gui_ { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow
{
	Q_OBJECT

public:
	//Attributes
	bool mwterminate = false;

	//Methods
	MainWindow(QWidget* parent = nullptr);
	~MainWindow();
	
private:
	//Attributes
	gui_::MainWindow *gui;
	
	//--------------------------------------------------------------------------------
	//Methods

private slots:
	//void on_action_File();

public slots:

};  // end of MainWindow
