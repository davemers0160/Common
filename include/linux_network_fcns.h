#ifndef _LINUX_NETWORK_FUNCTIONS_H
#define _LINUX_NETWORK_FUNCTIONS_H


#include <cstdint>
#include <cstring>
#include <string>
#include <vector>

#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

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

uint32_t init_udp_socket(int32_t port, int32_t &sock_fd, std::string &error_msg)
{

    error_msg = "";

    sock_fd = socket(PF_INET, SOCK_DGRAM, 0);
    if (sock_fd < 0) 
    {
        //error_msg = "socket: " + std::strerror(errno);
        error_msg = "socket: " + std::to_string(sock_fd);
        return -1;
    }

    struct sockaddr_in my_addr;
    memset((char*)&my_addr, 0, sizeof(my_addr));
    my_addr.sin_family = AF_INET;
    my_addr.sin_port = htons(port);
    my_addr.sin_addr.s_addr = INADDR_ANY;

    if (bind(sock_fd, (struct sockaddr*)&my_addr, sizeof(my_addr)) < 0) {
        //error_msg =  "bind: " + std::strerror(errno);
        error_msg =  "bind error";
        return -1;
    }

    struct timeval timeout;
    timeout.tv_sec = 1;
    timeout.tv_usec = 0;
    if (setsockopt(sock_fd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout)) < 0) {
        //error_msg = "setsockopt: " + std::strerror(errno);
        error_msg = "setsockopt error";
        return -1;
    }  
    
    return SUCCESS;
}   // end of init_udp_socket


uint32_t init_tcp_socket(std::string ip_address, uint32_t port, int32_t &sock_fd, std::string &error_msg)
{

    error_msg = "";
    
    sock_fd = -1;
    
    struct addrinfo hints, *info_start, *ai;

    memset(&hints, 0, sizeof hints);
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
  
    int ret = getaddrinfo(ip_address.c_str(), std::to_string(port).c_str(), &hints, &info_start);
    if (ret != 0) 
    {
        //error_msg = "getaddrinfo: " + gai_strerror(ret);
        error_msg = "getaddrinfo: " + std::to_string(ret);
        return -1;
    }

    if (info_start == NULL) 
    {
        error_msg = "getaddrinfo: empty result";
        return -1;
    }

    for (ai = info_start; ai != NULL; ai = ai->ai_next) 
    {
        sock_fd = socket(ai->ai_family, ai->ai_socktype, ai->ai_protocol);
        if (sock_fd < 0) {
            //error_msg = "socket: " + std::strerror(errno);
            error_msg = "socket: " + std::to_string(sock_fd);
            continue;
        }

        if (connect(sock_fd, ai->ai_addr, ai->ai_addrlen) == -1) 
        {
            close(sock_fd);
            error_msg += " connect==-1";
            continue;
        }

        break;
    }

    freeaddrinfo(info_start);
    if (ai == NULL) 
    {
        sock_fd = -1;
        error_msg += " ai==NULL";
        return -1;
    }
           
    return SUCCESS;

}   // end of init_tcp_socket



uint32_t send_message(int32_t &s, const std::string command, std::string &error_msg)
{

    error_msg = "";
    std::string cmd = command + "\n";

    ssize_t result = write(s, cmd.c_str(), cmd.length());
    if (result != (ssize_t)cmd.length()) {
        error_msg =  "init_client: failed to send command";
        return -1;
    }   
    
    //error_msg = "Send failed with error: (" + std::to_string(result) + " : " + std::to_string(WSAGetLastError()) + ")";

    return SUCCESS;

}   // end of send_message

// ----------------------------------------------------------------------------------------
/*
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
*/

// ----------------------------------------------------------------------------------------

uint32_t receive_message(int32_t &s, const uint32_t max_res_len, std::string &message)
{
    int32_t result;
    char *read_buf = new char[max_res_len + 1];

    result = recv(s, read_buf, max_res_len, 0);
    if (result < 0)
    {
        message = "Recieve failed: (" + std::to_string(result) + ")";
        return READ_FAILED;
    }

    read_buf[result] = '\0';

    message = std::string(read_buf);
    message.erase(message.find_last_not_of(" \r\n\t") + 1);

    return SUCCESS;

}   // end of receive_message


uint32_t close_connection(int32_t &s, std::string &error_msg)
{
    int32_t result = close(s);
    if (result == -1) {
        error_msg = "Closing socket failed with error: (" + std::to_string(result) + ")";
        return CLOSE_FAILED;
    }

    return SUCCESS;

}   // end of close_connection

#endif  // _LINUX_NETWORK_FUNCTIONS_H

