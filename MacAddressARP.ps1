$code=@'
/*
    add-type -path netstat3.cs
    [netstat]::GetEntries()
*/
using System;
using System.Text;
using System.Runtime.InteropServices;
using System.ComponentModel;
using System.Net;

public class NetStat{
        const int MAXLEN_PHYSADDR = 8;
        const int ERROR_INSUFFICIENT_BUFFER = 122;
        [StructLayout(LayoutKind.Sequential)]
        struct MIB_IPNETROW{
            [MarshalAs(UnmanagedType.U4)]
            public int dwIndex;
            [MarshalAs(UnmanagedType.U4)]
            public int dwPhysAddrLen;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac0;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac1;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac2;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac3;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac4;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac5;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac6;
            [MarshalAs(UnmanagedType.U1)]
            public byte mac7;
            [MarshalAs(UnmanagedType.U4)]
            public int dwAddr;
            [MarshalAs(UnmanagedType.U4)]
            public int dwType;
        }
        [DllImport("Iphlpapi.dll")]
        [return: MarshalAs(UnmanagedType.U4)]
        static extern int GetIpNetTable(
            IntPtr pIpNetTable,
            [MarshalAs(UnmanagedType.U4)]
            ref int pdwSize,
            bool border
        );
        public struct NetStatInfo{
            public string IPAddress;
            public string MacAddress;
        }
        
        public static NetStatInfo[] GetEntries(){
            
         int bytesNeeded = 0;
         int result = GetIpNetTable(IntPtr.Zero, ref bytesNeeded, false); 
 
         if (result != ERROR_INSUFFICIENT_BUFFER){ 
            throw new Win32Exception (result); 
         } 
 
         IntPtr buffer = IntPtr.Zero; 
 
         try{ 
            buffer = Marshal.AllocCoTaskMem (bytesNeeded); 
            result = GetIpNetTable (buffer, ref bytesNeeded, false); 
            if (result != 0){ 
               throw new Win32Exception (result); 
            } 
 
            int entries = Marshal.ReadInt32 (buffer); 
            IntPtr  currentBuffer = new IntPtr(buffer.ToInt64 () + Marshal.SizeOf (typeof (int))); 
            MIB_IPNETROW[] table = new MIB_IPNETROW[entries];
            for (int index = 0; index <entries; index++){
                
               //Call PtrToStructure, getting the information structure. 
               table [index] = (MIB_IPNETROW) Marshal.PtrToStructure (new 
                  IntPtr (currentBuffer.ToInt64 () + (index * 
                  Marshal.SizeOf (typeof (MIB_IPNETROW )))), typeof (MIB_IPNETROW)); 
            } 
 
            NetStatInfo[] rows = new NetStatInfo[entries];
            for (int index = 0; index < entries; index++){
                IPAddress ip = new IPAddress (table[index].dwAddr);
                NetStatInfo row = new NetStatInfo();
                row.IPAddress = ip.ToString();
                row.MacAddress=string.Format(
                                        @"{0:X2}-{1:X2}-{2:X2}-{3:X2}-{4:X2}-{5:X2}",
                                        table[index].mac0,
                                        table[index].mac1,
                                        table[index].mac2,
                                        table[index].mac3,
                                        table[index].mac4,
                                        table[index].mac5
                                        );
                rows[index]=row;
            }
            return rows;
         }
         
         finally{ 
            Marshal.FreeCoTaskMem (buffer); 
         }
    }
}
'@
Add-Type $code
[netstat]::GetEntries()
