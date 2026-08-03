import concurrent.futures
import ipaddress
import socket


def check_http_ip(ip, ports=(80, 443), timeout=1.0):
    ip_str = str(ip)

    for port in ports:
        try:
            # Create a TCP socket
            with socket.create_connection((ip_str, port), timeout=timeout):
                return ip_str, port
        except (socket.timeout, ConnectionRefusedError, OSError):
            continue

    return None


def scan_network_http(network_cidr, ports=(80, 443)):
    network = ipaddress.ip_network(network_cidr)
    print(
        f"Scanning {network_cidr} for open HTTP/HTTPS ports {ports}...\n"
    )

    active_hosts = []
    # Use ThreadPoolExecutor to scan asynchronously
    with concurrent.futures.ThreadPoolExecutor(max_workers=50) as executor:
        futures = [
            executor.submit(check_http_ip, ip, ports) for ip in network.hosts()
        ]
        for future in concurrent.futures.as_completed(futures):
            result = future.result()
            if result:
                host, port = result
                print(f"[+] Active HTTP service found: {host}:{port}")
                active_hosts.append(result)

    print(
        f"\nScan complete. Total HTTP services found: {len(active_hosts)}"
    )


if __name__ == "__main__":
    # Checks port 80 (HTTP) and 443 (HTTPS)
    scan_network_http("192.168.1.0/24", ports=(80, 443))
