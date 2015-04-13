defmodule Gateway.Utilities.NetworkTest do
  use ExUnit.Case, async: true
  alias Gateway.Utilities.Network

  doctest Network

  test "that interfaces are parsed to return string representations of IP and MAC Addresses" do
    assert sample_interfaces |> Network.parse_interfaces ==
        [{"eth0",
          [flags: [:up, :broadcast, :running, :multicast],
          hwaddr: "00:25:90:a6:f7:8c"]},
        {"eth1", [flags: [:broadcast, :multicast], hwaddr: "00:25:90:a6:f7:8d"]},
        {"wlan1",
          [flags: [:up, :broadcast, :running, :multicast], hwaddr: "10:fe:ed:1f:56:0d",
          addr: "172.16.0.184", netmask: "255.255.255.0", broadaddr: "172.16.0.255",
          addr: "FE80::12FE:EDFF:FE1F:560D", netmask: "FFFF:FFFF:FFFF:FFFF::"]}] 
  end

  defp sample_interfaces do
    [{'eth0',
      [flags: [:up, :broadcast, :running, :multicast],
      hwaddr: [0, 37, 144, 166, 247, 140]]},
    {'eth1',
      [flags: [:broadcast, :multicast], hwaddr: [0, 37, 144, 166, 247, 141]]},
    {'wlan1',
      [flags: [:up, :broadcast, :running, :multicast],
      hwaddr: [16, 254, 237, 31, 86, 13], addr: {172, 16, 0, 184},
      netmask: {255, 255, 255, 0}, broadaddr: {172, 16, 0, 255},
      addr: {65152, 0, 0, 0, 4862, 60927, 65055, 22029},
      netmask: {65535, 65535, 65535, 65535, 0, 0, 0, 0}]}]
  end

end
