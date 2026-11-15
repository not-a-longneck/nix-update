{ config, pkgs, ... }:
{  
  environment.systemPackages = with pkgs; [
    fluent-reader
    mediawriter
  
  ];
}
