#ifndef _WIN_NETWORK_FUNCTIONS_H
#define _WIN_NETWORK_FUNCTIONS_H

#define _WINSOCK_DEPRECATED_NO_WARNINGS 

#include <winsock2.h>
#include <ws2tcpip.h>
#include <iphlpapi.h>

#pragma comment(lib,"ws2_32.lib") //Winsock Library
#pragma comment(lib, "iphlpapi.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")

#include <cstdint>
#include <string>
#include <vector>

const uint16_t dllVersion = MAKEWORD(2, 2);

enum socket_errors { SUCCESS = 0,  
    WIN_START_ERR = 1, 
    GET_ADDRESS_ERROR = 2, 
    SOCKET_CREATION_ERR = 3, 
    SOCKET_BIND_ERR = 4, 
    CONNECTION_ERROR = 5, 
    SEND_ERROR = 6,
    READ_FAILED = 7,
    CLOSE_FAILED = 10
};

uint32_t init_udp_socket(int32_t port, SOCKADDR_IN &srcaddr, SOCKET &s, std::string &error_msg)
{
    WSADATA wsaData;
    int32_t result;

    error_msg = "";

    result = WSAStartup(dllVersion, &wsaData);
    if (result != 0) {
        error_msg = "Winsock startup failed. Error: " + std::to_string(result);
        return WIN_START_ERR;
    }

    // Create the socket
    s = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (s == INVALID_SOCKET) {
        result = WSAGetLastError();
        error_msg = "Socket creation failed. Error: " + std::to_string(result);
        return SOCKET_CREATION_ERR;
    }

    result = ::bind(s, (SOCKADDR*)&srcaddr, sizeof(srcaddr));
    if (result == SOCKET_ERROR) {
        result = WSAGetLastError();
        error_msg = "Socket bind failed. Error: " + std::to_string(result);
        return SOCKET_BIND_ERR;
    }

    return SUCCESS;
}   // end of init_udp_socket


uint32_t init_tcp_socket(std::string ip_address, uint32_t port, SOCKET &s, std::string &error_msg)
{
    WSADATA wsaData;
    int32_t result;
    SOCKADDR_IN server;

    struct addrinfo *add_result = NULL;
    struct addrinfo *ptr = NULL;
    struct addrinfo hints;

    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;

    error_msg = "";

    server.sin_addr.s_addr = inet_addr(ip_address.c_str());
    server.sin_family = AF_INET;
    server.sin_port = htons(port);

    // Initialize Winsock
    result = WSAStartup(dllVersion, &wsaData);
    if (result != 0) {
        error_msg = "Winsock startup failed. Error: " + std::to_string(result);
        return WIN_START_ERR;
    }

    // Create the socket
    s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (s == INVALID_SOCKET) {
        result = WSAGetLastError();
        error_msg = "Socket creation failed. Error: " + std::to_string(result);
        return SOCKET_CREATION_ERR;
    }

    //Connect to remote server
    result = connect(s, (struct sockaddr *)&server, sizeof(server));
    if (result == SOCKET_ERROR) {
        closesocket(s);
        s = INVALID_SOCKET;
        error_msg = "Socket connection failed. Error: " + std::to_string(result);
        return CONNECTION_ERROR;
    }


/*
    // Resolve the server address and port
    result = getaddrinfo(lidar_name.c_str(), port.c_str(), &hints, &add_result);
    if (result != 0) {
        error_msg = "getaddrinfo failed: (" + std::to_string(result) + " : " + std::to_string(WSAGetLastError()) + ")";
        WSACleanup();
        return GET_ADDRESS_ERROR;
    }

    // cycle through the returned address results to try and connect to the server
    for(ptr = add_result; ptr != NULL; ptr = ptr->ai_next)
    {
        // Create a SOCKET for connecting to server
        s = socket(ptr->ai_family, ptr->ai_socktype, ptr->ai_protocol);
        if (s == INVALID_SOCKET) {
            result = WSAGetLastError();
                error_msg = "Socket creation failed. Error: " + std::to_string(result);
                WSACleanup();
                return SOCKET_CREATION_ERR;
        }

        // Connect to server.
        result = connect(s, ptr->ai_addr, (int)ptr->ai_addrlen);
        if (result == SOCKET_ERROR) {
            closesocket(s);
            s = INVALID_SOCKET;
            error_msg = "Socket connection failed. Error: " + std::to_string(result);
            continue;
        }
        break;
    }   // end of for loop

    freeaddrinfo(add_result);

    if (s == INVALID_SOCKET) {
        error_msg +=  "\nUnable to connect to server!";
        WSACleanup();
        return CONNECTION_ERROR;
    }
*/
    return SUCCESS;

}   // end of init_tcp_socket



uint32_t send_message(SOCKET &s, const std::string command, std::string &message)
{
    int32_t result;

    message = "";
    std::string cmd = command + "\n";

    result = send(s, cmd.c_str(), (int32_t)cmd.length(), 0);
    if (result == SOCKET_ERROR) {
        message = "Send failed with error: (" + std::to_string(result) + " : " + std::to_string(WSAGetLastError()) + ")";
        closesocket(s);
        WSACleanup();
        return SEND_ERROR;
    }

    return SUCCESS;

}   // end of send_message

// ----------------------------------------------------------------------------------------
void get_ip_address(std::vector<std::string> &data, std::string &lpMsgBuf)
{
    int32_t idx;

    // Variables used by GetIpAddrTable 
    PMIB_IPADDRTABLE pIPAddrTable;
    unsigned long dwSize = 0;
    unsigned long dwRetVal = 0;
    in_addr IPAddr;

    data.clear();
    lpMsgBuf = "";

    // Before calling AddIPAddress we use GetIpAddrTable to get an adapter to which we can add the IP.
    pIPAddrTable = (MIB_IPADDRTABLE *)HeapAlloc(GetProcessHeap(), 0, sizeof(MIB_IPADDRTABLE));

    if (pIPAddrTable) 
    {
        // Make an initial call to GetIpAddrTable to get the necessary size into the dwSize variable
        if (GetIpAddrTable(pIPAddrTable, &dwSize, 0) ==
            ERROR_INSUFFICIENT_BUFFER) {
            HeapFree(GetProcessHeap(), 0, pIPAddrTable);
            pIPAddrTable = (MIB_IPADDRTABLE *)HeapAlloc(GetProcessHeap(), 0, dwSize);
        }

        if (pIPAddrTable == NULL) 
        {
            lpMsgBuf = "Memory allocation failed for GetIpAddrTable";
            return;
        }
    }

    // Make a second call to GetIpAddrTable to get the actual data we want
    if ((dwRetVal = GetIpAddrTable(pIPAddrTable, &dwSize, 0)) != NO_ERROR) 
    {
        FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS, NULL, dwRetVal, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), (LPTSTR)& lpMsgBuf, 0, NULL);
        return;
    }

    for (idx = 0; idx < (int)pIPAddrTable->dwNumEntries; ++idx) 
    {
        IPAddr.S_un.S_addr = (u_long)pIPAddrTable->table[idx].dwAddr;
        data.push_back(inet_ntoa(IPAddr));
    }

    if (pIPAddrTable) 
    {
        HeapFree(GetProcessHeap(), 0, pIPAddrTable);
        pIPAddrTable = NULL;
    }

}   // end of get_ip_address

uint32_t receive_message(SOCKET &s, const uint32_t max_res_len, std::string &message)
{
    int32_t result;
    char *read_buf = new char[max_res_len + 1];

    result = recv(s, read_buf, max_res_len, 0);
    if (result < 0)
    {
        message = "Recieve failed: (" + std::to_string(result) + " : " + std::to_string(WSAGetLastError()) + ")";
        return READ_FAILED;
    }

    read_buf[result] = '\0';

    message = std::string(read_buf);
    message.erase(message.find_last_not_of(" \r\n\t") + 1);

    return SUCCESS;

}   // end of receive_message


uint32_t close_connection(SOCKET &s, std::string &error_msg)
{
    int32_t result = shutdown(s, SD_SEND);
    if (result == SOCKET_ERROR) {
        error_msg = "Shutdown failed with error: (" + std::to_string(result) + " : " + std::to_string(WSAGetLastError()) + ")";
        closesocket(s);
        WSACleanup();
        return CLOSE_FAILED;
    }

    return SUCCESS;

}   // end of close_connection

#endif  // _WIN_NETWORK_FUNCTIONS_H

