## nixos configuration


https://nixos.wiki/wiki/Overview_of_the_NixOS_Linux_distribution#Declarative_Configuration


## NixOS üzerinde kullanım

öncelikle unstable paket yoneticisi aktive edilir.

```shell
nix registry add pkgs github:nixos/nixpkgs/nixos-unstable
```

daha sonra bir klasörde alttaki komut ile flake projesi oluşturulur

```shell
mkdir muratpc-test

nix flake new --template templates#full ./muratpc-test

```

klasöre gidip baktığımızda flake.nix ve flake.lock dosyaları oluşmuş olmalıdır.

flake.nix dosyasında baktığımızda alttaki gibi uzun bir doya ile karşılaşıyor olacağız.

```nix
{
  description = "A template that shows all standard flake outputs";

  # Inputs
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake.html#flake-inputs

  # The flake in the current directory.
  # inputs.currentDir.url = ".";

  # A flake in some other directory.
  # inputs.otherDir.url = "/home/alice/src/patchelf";

  # A flake in some absolute path
  # inputs.otherDir.url = "path:/home/alice/src/patchelf";

  # The nixpkgs entry in the flake registry.
  inputs.nixpkgsRegistry.url = "nixpkgs";

  # The nixpkgs entry in the flake registry, overriding it to use a specific Git revision.
  inputs.nixpkgsRegistryOverride.url = "nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";

  # The master branch of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgsGitHub.url = "github:NixOS/nixpkgs";

  # The nixos-20.09 branch of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgsGitHubBranch.url = "github:NixOS/nixpkgs/nixos-20.09";

  # A specific revision of the NixOS/nixpkgs repository on GitHub.
  inputs.nixpkgsGitHubRevision.url = "github:NixOS/nixpkgs/a3a3dda3bacf61e8a39258a0ed9c924eeca8e293";

  # A flake in a subdirectory of a GitHub repository.
  inputs.nixpkgsGitHubDir.url = "github:edolstra/nix-warez?dir=blender";

  # A git repository.
  inputs.gitRepo.url = "git+https://github.com/NixOS/patchelf";

  # A specific branch of a Git repository.
  inputs.gitRepoBranch.url = "git+https://github.com/NixOS/patchelf?ref=master";

  # A specific revision of a Git repository.
  inputs.gitRepoRev.url = "git+https://github.com/NixOS/patchelf?ref=master&rev=f34751b88bd07d7f44f5cd3200fb4122bf916c7e";

  # A tarball flake
  inputs.tarFlake.url = "https://github.com/NixOS/patchelf/archive/master.tar.gz";

  # A GitHub repository.
  inputs.import-cargo = {
    type = "github";
    owner = "edolstra";
    repo = "import-cargo";
  };

  # Inputs as attrsets.
  # An indirection through the flake registry.
  inputs.nixpkgsIndirect = {
    type = "indirect";
    id = "nixpkgs";
  };

  # Non-flake inputs. These provde a variable of type path.
  inputs.grcov = {
    type = "github";
    owner = "mozilla";
    repo = "grcov";
    flake = false;
  };

  # Transitive inputs can be overridden from a flake.nix file. For example, the following overrides the nixpkgs input of the nixops input:
  inputs.nixops.inputs.nixpkgs = {
    type = "github";
    owner = "NixOS";
    repo = "nixpkgs";
  };

  # It is also possible to "inherit" an input from another input. This is useful to minimize
  # flake dependencies. For example, the following sets the nixpkgs input of the top-level flake
  # to be equal to the nixpkgs input of the nixops input of the top-level flake:
  inputs.nixpkgs.url = "nixpkgs";
  inputs.nixpkgs.follows = "nixops/nixpkgs";

  # The value of the follows attribute is a sequence of input names denoting the path
  # of inputs to be followed from the root flake. Overrides and follows can be combined, e.g.
  inputs.nixops.url = "nixops";
  inputs.dwarffs.url = "dwarffs";
  inputs.dwarffs.inputs.nixpkgs.follows = "nixpkgs";

  # For more information about well-known outputs checked by `nix flake check`:
  # https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake-check.html#evaluation-checks

  # These examples all use "x86_64-linux" as the system.
  # Please see the c-hello template for an example of how to handle multiple systems.

  inputs.c-hello.url = "github:NixOS/templates?dir=c-hello";
  inputs.rust-web-server.url = "github:NixOS/templates?dir=rust-web-server";
  inputs.nix-bundle.url = "github:NixOS/bundlers";

  # Work-in-progress: refer to parent/sibling flakes in the same repository
  # inputs.c-hello.url = "path:../c-hello";

  outputs = all@{ self, c-hello, rust-web-server, nixpkgs, nix-bundle, ... }: {

    # Utilized by `nix flake check`
    checks.x86_64-linux.test = c-hello.checks.x86_64-linux.test;

    # Utilized by `nix build .`
    defaultPackage.x86_64-linux = c-hello.defaultPackage.x86_64-linux;

    # Utilized by `nix build`
    packages.x86_64-linux.hello = c-hello.packages.x86_64-linux.hello;

    # Utilized by `nix run .#<name>`
    apps.x86_64-linux.hello = {
      type = "app";
      program = c-hello.packages.x86_64-linux.hello;
    };

    # Utilized by `nix bundle -- .#<name>` (should be a .drv input, not program path?)
    bundlers.x86_64-linux.example = nix-bundle.bundlers.x86_64-linux.toArx;

    # Utilized by `nix bundle -- .#<name>`
    defaultBundler.x86_64-linux = self.bundlers.x86_64-linux.example;

    # Utilized by `nix run . -- <args?>`
    defaultApp.x86_64-linux = self.apps.x86_64-linux.hello;

    # Utilized for nixpkgs packages, also utilized by `nix build .#<name>`
    legacyPackages.x86_64-linux.hello = c-hello.defaultPackage.x86_64-linux;

    # Default overlay, for use in dependent flakes
    overlay = final: prev: { };

    # # Same idea as overlay but a list or attrset of them.
    overlays = { exampleOverlay = self.overlay; };

    # Default module, for use in dependent flakes. Deprecated, use nixosModules.default instead.
    nixosModule = { config, ... }: { options = {}; config = {}; };

    # Same idea as nixosModule but a list or attrset of them.
    nixosModules = { exampleModule = self.nixosModule; };

    # Used with `nixos-rebuild --flake .#<hostname>`
    # nixosConfigurations."<hostname>".config.system.build.toplevel must be a derivation
    nixosConfigurations.example = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [{boot.isContainer=true;}] ;
    };

    # Utilized by `nix develop`
    devShell.x86_64-linux = rust-web-server.devShell.x86_64-linux;

    # Utilized by `nix develop .#<name>`
    devShells.x86_64-linux.example = self.devShell.x86_64-linux;

    # Utilized by Hydra build jobs
    hydraJobs.example.x86_64-linux = self.defaultPackage.x86_64-linux;

    # Utilized by `nix flake init -t <flake>`
    defaultTemplate = {
      path = c-hello;
      description = "template description";
    };

    # Utilized by `nix flake init -t <flake>#<name>`
    templates.example = self.defaultTemplate;
  };
}
```

burada inpup olarak adlandırılanlar c# daki using blokları gibidir. yani kullanılacak paketleri belirliyor. 

output ise bu paketleri kullanarak sistemi oluşturan kod bloklarını gösteriyor.

Bu örnekte full template olduğu için neredeyse tüm flake outputlarını gösteriyor.


sade bir örneğe bakalım

```nix
{
  description = "Ryan'ın NixOS Flake'i";

  # Bu, flake.nix için standart biçimidir.
  # `inputs`, flake'in bağımlılıklarıdır,
  # ve `outputs` işlevi, flake'in tüm derleme sonuçlarını döndürecektir.
  # `inputs` içindeki her öğe, çekildikten ve derlendikten sonra
  # `outputs` işlevine bir parametre olarak iletilir.
  inputs = {
    # Flake girişlerini başvurmanın birçok yolu vardır.
    # En yaygın olarak kullanılanı `github:owner/name/reference`'dir,
    # Bu, GitHub deposu URL + branch/commit-id/tag temsil eder.

    # Resmi NixOS paket kaynağı, burada nixos-unstable branch ini kullanıyor
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Kullanıcı yapılandırmasını yönetmek için kullanılan home-manager
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      # `inputs` içindeki `home-manager`'ın `inputs.nixpkgs`'nin
      # güncel flake'in `inputs.nixpkgs` ile tutarlı kalmasını sağlamak için kullanılan `follows` anahtar kelimesi.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # `outputs`, flake'in tüm derleme sonuçlarıdır.
  #
  # Bir flake'in birçok kullanım ve farklı türde çıktıları olabilir.
  # 
  # `outputs` işlevindeki parametreler, `inputs` içinde tanımlanır ve
  # adlarıyla başvurulabilir. Ancak `self` bir istisnadır,
  # bu özel parametre, `outputs`'un kendisine işaret eder (self-referans).
  # 
  # Buradaki `@` sözdizimi, giriş parametresinin öznitelik kümesini takma adlandırmak için kullanılır,
  # işlev içinde kullanmak daha uygun hale gelir.
  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      # Varsayılan olarak, NixOS, nixosConfiguration'ı ana makine adıyla bulmaya çalışacaktır,
      # bu nedenle 'nixos-test' adlı sistem bu yapılandırmayı kullanacaktır.
      # Ancak, yapılandırma adı aşağıdaki gibi belirtilebilir:
      #   sudo nixos-rebuild switch --flake /path/to/flakes/directory#<name>
      #
      # Bu yapılandırmayı herhangi bir NixOS sisteminde dağıtmak için flake'in dizininde
      # aşağıdaki komutu çalıştırın:
      #   sudo nixos-rebuild switch --flake .#nixos-test
      "nixos-test" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        # Nix modül sistemi, yapılandırmanın bakımını iyileştiren
        # bir şekilde yapılandırmayı modüler hale getirebilir.
        #
        # `modules` içindeki her parametre, bir Nix Modülüdür ve
        # nixpkgs el kitabında kısmi bir tanıtımı vardır:
        #    <https://nixos.org/manual/nixpkgs/unstable/#module-system-introduction>
        # Bu kısmi olduğu söylenir çünkü belge tamamlanmamıştır,
        # yalnızca bazı basit tanıtımlar bulunur.
        # işte Nix belgesinin şu anki durumu...
        #
        # Bir Nix Modülü bir öznitelik kümesi veya bir öznitelik kümesi döndüren bir işlev olabilir.
        # Varsayılan olarak, bir Nix Modülü işlevse, bu işlevin aşağıdaki varsayılan parametreleri vardır:
        #
        #  lib:     nixpkgs işlev kitaplığı, Nix ifadeleriyle işlem yapmak için birçok
        #             faydalı işlev sağlar:
        #             https://nixos.org/manual/nixpkgs/stable/#id-1.4
        #  config:  mevcut flake'in tüm yapılandırma seçenekleri, her biri kullanışlıdır
        #  options: mevcut flake içindeki tüm NixOS Modüllerinde tanımlanan tüm seçenekler
        #  pkgs:   nixpkgs'de tanımlanan tüm paketlerin bir koleksiyonu,
        #            paketleme ile ilgili bir dizi işlevi içerir.
        #            Şu an için varsayılan değeri
        #            `nixpkgs.legacyPackages."${system}"` olarak varsayabilirsiniz.
        #            `nixpkgs.pkgs` seçeneği ile özelleştirilebilir
        #  modulesPath: nixpkgs'in modüller klasörünün varsayılan yolu,
        #               nixpkgs'den ekstra modülleri içe aktarmak için kullanılır.
        #               bu parametre nadiren kullanılır,
        #               şu an için bunu göz ardı edebilirsiniz.
        #
        # Yukarıda bahsedilen varsayılan parametreler Nixpkgs tarafından otomatik olarak oluşturulur.
        # Ancak, alt modüllere diğer varsayılan olmayan parametreleri iletmek isterseniz,
        # bu parametreleri 'specialArgs' kullanarak manuel olarak yapılandırmanız gerekecektir.
        # Aşağıdaki satırı yorum satırından çıkartarak 'specialArgs' kullanmanız gerekebilir:
        #
        # specialArgs = {...};  # Tüm alt modüllere özel argümanları iletmek için
modules = [
          # Import the configuration.nix here, so that the
          # old configuration file can still take effect.
          # Note: configuration.nix itself is also a Nix Module,
          ./configuration.nix
        ];
      };
    };
  };
}
```


şimdi gerçek sistemimiz için çalışmalya başlayalım.


bunun için öncelikle mcabukpc adında bir klasör oluşturuz. ve içine flake.nix adında bir dosya oluşturuyıruz.

```shell
mkdir mcabukpc

touch flake.nix
```
içine alttaki blokları yazıyoruz

```nix
{
  description = "Murat Cabuk NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };
  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      my-hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
    defaultPackage = nixpkgs.legacyPackages.x86_64-linux.hello;
  };
}

```

aynı dizine bir de configuration.nix dosyası oluşturuyoruz.

```nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "muratpc"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = ["nix-command" "flakes"];


  # Set your time zone.
  time.timeZone = "Europe/Istanbul";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "tr_TR.UTF-8";
    LC_IDENTIFICATION = "tr_TR.UTF-8";
    LC_MEASUREMENT = "tr_TR.UTF-8";
    LC_MONETARY = "tr_TR.UTF-8";
    LC_NAME = "tr_TR.UTF-8";
    LC_NUMERIC = "tr_TR.UTF-8";
    LC_PAPER = "tr_TR.UTF-8";
    LC_TELEPHONE = "tr_TR.UTF-8";
    LC_TIME = "tr_TR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "tr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "trq";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.muratcabuk = {
    isNormalUser = true;
    description = "murat cabuk";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     git
     curl
  ];
    
   environment.variables.EDITOR = "vim";

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
    services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}


```

bide hardware-configuration.nix adında bir dosya oluşturupo alttaki kodları yazıyoruz. bu dosya aslında il kurulumda zaten sisitem tarafından oluşturuluyor. dizin olarak ta /etc/nixos klasöründe bulabilirsiniz. ben de sanal makinemde kurduğumda oluşmuş olanı buraya kopyaladım.

```nix
# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/profiles/qemu-guest.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/dab4ff6b-f67b-4fa7-9eed-42bfe3d12ef3";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3D92-0C66";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/cce01581-8b10-4d0f-96a8-c574069c7963";
      fsType = "btrfs";
    };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp1s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}

```

artık dosyalarımızı kullanarak sistemmimizi kurabiliriz. buraya kadar aslında nix dilini kullanarak birşeyler yaptık. nixos u ayaralaak ve kullanmak için nix komutları değil nixos komutları kullanılır.




- nixos-rebuild switch: Yeni bir yapılandırmayı etkinleştirir.
- nixos-rebuild boot: Önceki yapılandırmaya geri dönme olanağı sağlar.
- nixos-rebuild build: Yeni yapılandırmayı oluşturur ancak etkinleştirmez.
- nixos-rebuild test: Yapılandırmayı test etmek için kullanılır.




`nixos-rebuild switch` komutu, NixOS işletim sisteminin yapılandırmasını değiştirmek ve yeni bir yapılandırmayı etkinleştirmek için kullanılan önemli bir komuttur. Bu komut tam olarak şunları yapar:

1. **Yeni Yapılandırmayı Derleme**: `nixos-rebuild switch` komutu, belirtilen NixOS yapılandırma dosyasını veya Flake'i kullanarak yeni bir sistem yapılandırması derler. Bu, Nix paketlerini ve yapılandırmalarını gerektiği gibi alarak yeni bir sistem görüntüsünü oluşturur.

2. **Aktif Yapılandırmayı Değiştirme**: Komut, mevcut aktif yapılandırmayı değiştirir. Yani, sistem üzerindeki mevcut yapılandırmayı devre dışı bırakır ve yeni yapılandırmayı etkinleştirir.

3. **Yapılandırmayı Geri Alabilme**: Komut çalıştırıldığında, eski yapılandırma hala sistemde bulunur. Bu, herhangi bir hata durumunda veya yeni yapılandırmanın beklenmedik bir şekilde çalışmaması durumunda eski yapılandırmaya geri dönebilme olanağı sunar. Bu, `nixos-rebuild boot` komutuyla yapılır.

4. **Çakışmaları Önler**: NixOS, yapılandırmaları ve paketleri izole edilmiş bir çevrede sakladığı için, yapılandırma değişiklikleri veya yeni paketler yükleme, var olan yapılandırmaları etkilemez. Bu, sistemin kararlılığını artırır.

5. **Sistem Yapılandırması Değiştirme**: Yeni yapılandırma, sistemin genel yapılandırmasını değiştirir. Bu, kullanıcıların NixOS işletim sisteminin davranışını veya bileşenlerini değiştirmelerine olanak tanır.

Özetle, `nixos-rebuild switch` komutu, yeni bir NixOS sistem yapılandırması derler ve etkinleştirir, eski yapılandırmayı devre dışı bırakır ve sistem yapılandırmasını değiştirir. Bu, NixOS'un sistem yapılandırmasını güncellemek ve değiştirmek için kullanılan temel bir komuttur.






```shell

nixos-rebuild switch 
```



