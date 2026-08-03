import concurrent.futures
import ipaddress
import platform
import subprocess

# Detect platform for ping flags (-c for Unix-like, -n for Windows)
PARAM = "-n" if platform.system().lower() == "windows" else "-c"
TIMEOUT_PARAM = "-w" if platform.system().lower() == "windows" else "-W"


def ping_ip(ip):
    ip_str = str(ip)
    # Ping once, wait up to 1000ms for response
    cmd = ["ping", PARAM, "1", TIMEOUT_PARAM, "1000", ip_str]

    result = subprocess.run(
        cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
    )
    if result.returncode == 0:
        return ip_str
    return None


def scan_network(network_cidr):
    network = ipaddress.ip_network(network_cidr)
    print(f"Scanning {network_cidr} for active hosts...\n")

    active_hosts = []
    # Use ThreadPoolExecutor to scan asynchronously
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        results = executor.map(ping_ip, network.hosts())
        for result in results:
            if result:
                print(f"[+] Active host found: {result}")
                active_hosts.append(result)

    print(f"\nScan complete. Total active hosts found: {len(active_hosts)}")


if __name__ == "__main__":
    scan_network("192.168.1.0/24")
