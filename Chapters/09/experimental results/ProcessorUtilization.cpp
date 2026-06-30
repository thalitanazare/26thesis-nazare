/*
Author: Jordan Browne.
This Program is ideally compiled using the command g++ ProcessorUtilization.cpp -o ProcessorUtilization -lstdc++ -lkernel32 -mwindows, this worked for me on my machine,
as there were some issues on my compiler, the -mwindows flag allows the file to be run without creating a blank terminal. when the program is run it monitors the CPU utilization
of MATLAB.exe and sends this information to an output text file, in the form "Time,cpuUtilization,CPUTime" the Utilization is in the form of a percent and may look different
to the value in task manager due to different sampling times, but the math is the same.
*/



#define _WIN32_WINNT 0x0602
#include <iostream>
#include <windows.h>
#include <psapi.h> 
#include <tlhelp32.h>
#include <vector>
#include <chrono>
#include <fstream>


//declare old system and process times, these will be refreshed after each run of the getProcessCPUUtilization function

long double oldProcessKernelTime = 0;
long double oldProcessUserTime = 0;
long double oldElapsedTime = 0;
long double oldSystemKernelTime = 0;
long double oldSystemUserTime = 0;
static const auto startTime = std::chrono::steady_clock::now();

//this function returns the CPU utilization, time of measurement, and CPU time used betweem samples
std::string getProcessCPUUtilization(DWORD processId)
{
    //Create FileTime Variables
    FILETIME createTime, exitTime, processKernelTime, processUserTime, idleTime, kernelTime, userTime;

    SYSTEM_INFO systemInfo;
    GetSystemInfo(&systemInfo);

    if (!GetSystemTimes(&idleTime, &kernelTime, &userTime))
    {
        std::cerr << "Failed to get system times." << std::endl;
        return "0.0";
    }

    HANDLE processHandle = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, processId);
    if (processHandle == NULL)
    {
        std::cerr << "Failed to open process with ID: " << processId << std::endl;
        return "0.0";
    }

    if (GetProcessTimes(processHandle, &createTime, &exitTime, &processKernelTime, &processUserTime) == 0)
    {
        std::cerr << "Failed to get process times for process ID: " << processId << std::endl;
        CloseHandle(processHandle);
        return "0.0";
    }

    CloseHandle(processHandle);

    // Convert the FILETIME objects to long doubles in milliseconds
    long double newSystemKernelTime = (static_cast<ULONGLONG>(kernelTime.dwLowDateTime) + (static_cast<ULONGLONG>(kernelTime.dwHighDateTime) << 32)) / 10000.0;
    long double newSystemUserTime = (static_cast<ULONGLONG>(userTime.dwLowDateTime) + (static_cast<ULONGLONG>(userTime.dwHighDateTime) << 32)) / 10000.0;
    long double newProcessKernelTime = (static_cast<ULONGLONG>(processKernelTime.dwLowDateTime) + (static_cast<ULONGLONG>(processKernelTime.dwHighDateTime) << 32)) / 10000.0;
    long double newProcessUserTime = (static_cast<ULONGLONG>(processUserTime.dwLowDateTime) + (static_cast<ULONGLONG>(processUserTime.dwHighDateTime) << 32)) / 10000.0;

    // Calculate elapsed processor and process times
    long double elapsedProcessorTime = (newSystemKernelTime - oldSystemKernelTime) + (newSystemUserTime - oldSystemUserTime);
    long double elapsedProcessTime = (newProcessKernelTime - oldProcessKernelTime) + (newProcessUserTime - oldProcessUserTime);

    // Calculate CPU utilization
    long double cpuUtilization = (elapsedProcessTime / elapsedProcessorTime) * 100.0;

    // Check for division by zero or first run
    if (elapsedProcessorTime == 0.0 || oldProcessKernelTime == 0.0)
    {
        cpuUtilization = 0.0;
    }

    auto currentTime = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now() - startTime).count();
    long double midPointTime = (currentTime + oldElapsedTime) / 2.0;

    std::string result = std::to_string(midPointTime) + "," + std::to_string(cpuUtilization) + "," + std::to_string(elapsedProcessTime);

    // Update old times
    oldProcessKernelTime = newProcessKernelTime;
    oldProcessUserTime = newProcessUserTime;
    oldSystemKernelTime = newSystemKernelTime;
    oldSystemUserTime = newSystemUserTime;
    oldElapsedTime = currentTime;

    return result;
}





int main()
{
    std::ofstream outputFile("Output.txt", std::ios::trunc);
    if (!outputFile.is_open())
    {
        std::cerr << "Failed to open output file" << std::endl;
        return 1;
    }

    const std::string processName = "MATLAB.exe";
    const long double measurementInterval = 100; // Interval between measurements in milliseconds

    DWORD processId = 0;
    PROCESSENTRY32 processEntry;
    processEntry.dwSize = sizeof(PROCESSENTRY32);

    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (Process32First(snapshot, &processEntry))
    {
        while (Process32Next(snapshot, &processEntry))
        {
            if (processName.compare(processEntry.szExeFile) == 0)
            {
                processId = processEntry.th32ProcessID;
                break;
            }
        }
    }
    CloseHandle(snapshot);

    if (processId == 0)
    {
        std::cerr << "Failed to find the process with name: " << processName << std::endl;
        return 1;
    }

    while (true)
    {
        std::string cpuUtilization = getProcessCPUUtilization(processId); 
        outputFile << cpuUtilization << std::endl; 
    }

    return 0;
}








