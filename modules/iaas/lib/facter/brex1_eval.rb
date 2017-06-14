# brex1_eval.rb
# Evaluate the status of br-ex1 in the network node

Facter.add(:brex1_eval) do
  setcode do
    Facter::Util::Resolution.exec("/usr/bin/ovs-vsctl br-get-external-id br-ex1 | /usr/bin/awk -F= '{print $2}'")
  end
end
