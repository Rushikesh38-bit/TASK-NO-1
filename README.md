# TASK-NO-1
NETWORK RECONNAISSANCE WITH NMAP

Overview:
This repository documents a practical network reconnaissance task to identify open ports and services on devices within a local network using Nmap. It includes step-by-step instructions, sample commands, and space for your screenshots.

Step-by-Step Working:

Step 1: Find Your IP Address and Network Range

  Open your terminal or command prompt.
  Use the following commands:


        Windows: ipconfig

        Linux: ifconfig    
    
  Note your IP address.
  Determine your network range (192.168.1.0/24).
  

Step 2: Perform a Basic TCP SYN Scan with Nmap

  Open your terminal/command prompt
   Run the following command, replacing <your_network_range> with your network range:

  
         nmap -sS 192.168.1.0/24

        
  This performs a stealth scan to identify open TCP ports on devices
  

Step 3: Save the Scan Results

           
          nmap -sS 192.168.1.0/24 -oA scan_results  
                 

   To save detailed results in multiple formats:
   
   
            scan_results.nmap (normal output)
            scan_results.xml (XML format)
            scan_results.gnmap (grepable format)


Step 4: Analyze the Results


   Open the saved files to review:
   
   IP addresses of devices
   Open ports
   Services associated with each port


Important Notes:


   1] Always ensure you have permission to scan a network.
   
   2] Use the results to understand potential security risks.
   
   3] Close unnecessary open ports to improve security.


Output:

        
