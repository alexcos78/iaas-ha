# brex1_eval.rb
# Evaluate the status of br-ex1 in the network node

Facter.add(:brtun_eval) do
  setcode do
    Facter::Util::Resolution.exec("ip link |grep br-tun |grep UP")
  end
end
