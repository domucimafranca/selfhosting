# Flush all iptables and ip6tables rules and chains

# Loop through all firewall table names
for ipt in iptables iptables-legacy ip6tables ip6tables-legacy; do

  # Flush all rules from the table
  $ipt --flush

  # Flush all NAT rules from the table
  $ipt --flush -t nat

  # Delete all user-defined chains from the table
  $ipt --delete-chain

  # Delete all user-defined NAT chains from the table
  $ipt --delete-chain -t nat

  # Set the default policy for the FORWARD chain to ACCEPT
  $ipt -P FORWARD ACCEPT

  # Set the default policy for the INPUT chain to ACCEPT
  $ipt -P INPUT ACCEPT

  # Set the default policy for the OUTPUT chain to ACCEPT
  $ipt -P OUTPUT ACCEPT

done

# This script effectively resets all firewall rules and chains to their default states.

