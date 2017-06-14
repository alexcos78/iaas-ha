# brex2_eval.rb
# Evaluate the status of br-ex1 in the network node

Facter.add(:brex2_eval) do
  setcode do
    Facter::Util::Resolution.exec("/usr/bin/ovs-vsctl br-get-external-id br-ex2 | /usr/bin/awk -F= '{print $2}'")
  end
end
