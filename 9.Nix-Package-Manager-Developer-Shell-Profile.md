# Nix Paket Yöneticisi ile Developer ve Profile Ortamları Oluşturmak (Nix Öğreniyoruz 9)

Önceki yazılarımızda  `nix shell` ve `nix profile` komutlarını görmüştük. Ancak oralara yatığımız örneklerde imperative bir yol izlemiştik. Kurmak istediğimiz developer ortamı için `nix shell` komutu ile  bütün uygulamaları ve paketleri manuel olarak her defasından yüklemek zorundaydık. Yada oluşturduğumuz bir profile her defasında yeniden oluşturmak durumundaydık. İlgili yazımızda da belirttiğimiz gibi bu zaten Nix felsefesine çok da uyan bir yaklaşım değil. Zaten o zamanda bunu declarative versiyonunu ileride göreceğimizden bahsetmiştik. Çünkü arada declarative kurguyu biraz anlamamız gerekiyordu. Artık kaldığımız yeren devam edebiliriz.  


1. [NixOS: İşletim Sistemlerine Fonksiyonel Yaklaşım](0.NixOs.md)
2. [Nix Dili ve Özellikleri](1.NixLanguage.md)
3. [Nix Dili ile ilgili Alıştırmalar](2.NixLanguage-Exercises.md)
4. [Nix Dilinde Builtins Fonksiyonlar](3.NixLanguage-Builtins.md) 
5. [Nix Paket Yöneticisi](4.Nix-Package-Manager.md)
6. [Nix Paket Yöneticisi Shell, Profile Kavram ve Komutları](5.Nix-Package-Manager-Shell-Profile.md)
7. [Nix Flake Nedir?](6.Nix-Package-Flake-CustomDerivation.md)
8. [Birden Çok Paketi Aynı Repo Üzeriden Yayınlamak](7.Nix-Package-Flake-CustomDerivation-Multiple.md) 
9. [Override ve Overlay Kavramları](8.Nix-Package-Overlay-Overrride.md)
10. [Nix Paket Yöneticisi ile Developer ve Profile Ortamları Oluşturmak](9.Nix-Package-Manager-Developer-Shell-Profile.md) 
11. [Nix ile NixOs Konfigürasyonu](10.Nix-With-NixOS.md) 
12. [NixOs Module ve Option Kullanımı](11.Nix-Nixos-Modules-Options.md)
13. [NixOs Kurulumu ve Konfigürasyonu](12.Nix-NixOs-Configuration.md)
14. [NixOs'u Cloud ve Uzak Ortamlara Deploy Etmek](13.Nix-With-NixOS-Iso-Docker-Cloud.md)

## Nix Shell Declarative Kullanımı

Yeni kurguda aslında `nix shell` doğrudan nix dosyaları üzerinden declarative olarak kurum yapmıyor. Ancak `nix develop` komutu bu işi yapıyor. Ancak declarative sayılabilecek güzel kullanımları mevcut. Detayları resmi dokümanlarından da bakabilirsiniz. Bir kısmını burada test edeceğiz.

Mesela alttaki gibi kullanımları olduğunu daha önce görmüştük.



```bash
nix shell nixpkgs#youtube-dl
youtube-dl --version

#2021.12.17

nix shell nixpkgs/nixos-20.03#hello
hello
# Hello, world!

nix shell nixpkgs#hello --command hello --greeting 'Hi everybody!'
# Hi everybody!

# aynı diznide yer alan bir flake.nix dosyasının export ettiği paketleri yüklyebiliriz.
nix shell .
```

Daha bir çok örnek bulabilirsiniz. Temel amacı terminal açıkken bir uygulamayı kullanmak veya sadece test emek için kurmamızı sağlıyor. Bunu haricinde `nix shell` komutunu [shebang interpreter](https://en.wikipedia.org/wiki/Shebang_%28Unix%29) olarak da kullanılabilir.


Örneğin alttaki python kodunu bir dosyaya kaydedip (örneğin test.py) daha sonra `python3 test.py` komutuyla çalıştırdığımızda `ModuleNotFoundError: No module named prettytable` hatası alırız. Çünkü prettytable modülü yüklü değil. 


```python
import prettytable

# Print a simple table.
t = prettytable.PrettyTable(["N", "N^2"])
for n in range(1, 10): t.add_row([n, n * n])
print (t)
```

Şimdi aynı dosyyı alttaki gibi editleyelim. `#!` başlayan satırlara shebang diyoruz. Bu satırlar ile ilgili dosyanın öncelikle nix shell ile açılıp gerekli paketler yüklendikten sonra python ile çalıştıracağını belirtiyoruz. `test.py` dosyasını öncelikle `chmod +x test.py` komutuyka çalıştırılabilir yapıp daha sonra `./test.py` ile terminalden çalıştırıoyruz. Böyllece `prettytable` modülü yüklendikten sonra python kodu çalıştırılmış oluyor. 

```python
#! /usr/bin/env -S nix shell github:tomberek/-#python3With.prettytable --command python

import prettytable

# Print a simple table.
t = prettytable.PrettyTable(["N", "N^2"])
for n in range(1, 10): t.add_row([n, n * n])
print (t)
```

Mesela alttaki shell script'inde ise çok satırlı bir Nix expression çalıştırılıyor. Terraform çalıştırılmadan önce expression çalıştırılıyor ilgili plugin'ler yüklendikten sonra Terraform çalıştırılıyor.

```bash
#! /usr/bin/env nix
#! nix shell --impure --expr ``
#! nix with (import (builtins.getFlake ''nixpkgs'') {});
#! nix terraform.withPlugins (plugins: [ plugins.openstack ])
#! nix ``
#! nix --command bash

terraform "$@"

```


## Nix Develop Kullanımı

`Nix develop` komutu daha önce `nix-shell` komutu yerine geldi. Önceden (genellikle) adı shell.nix olan bir dosya içinde mkShell fonksiyonu yazılır ve `nix shell` komutu shell.nix dosyasının bulunduğu dizinde çalıştırıldığında ilgili uygulamalar kurulurdu. Ancak yeni versiyonda artık bence daha anlamlı olan `nix develop` komutu geldi. Amacımız halen aynı yani üzerinden çalışmakta olduğumuz projenin isterleri olan uygulama ve paketlerin kurulumunu yapmak. Ancak bu sefer tek tek yüklemiyoruz bunun yerine ilgili paketve uygulamaları flake dosyamıza yazıyoruz ve oradan yüklüyoruz.


Flake doaylarımızla bu yazıya kadar derivative ve paxkage oluşturduk. Şimdi ise flake dosyalarımızı kullanarak `nix develop` komutu ile bir developer ortamı oluşturacağız. Bunun içinde  daha önce paket export ederken kullandığımız `packages.<system>.default` yapısına bencer  olan `devShells.<system>.default` yapısını kullanıyoruz. [Resmi dokümanlardan](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-develop.html) da konuyu detaylı inceleyebilirsiniz.

Şimdi biraz örnek yapalım. Diyelimki bir backend'i dotnet 8, frontend'i ise NodeJs 18 olan bir web uygulaması geliştiriyoruz. Bu uygulama için gerekli olan .net core sdk'sını, nodejs'i, npm'i, yarn'ı ve pnpm'i kullanmak istiyoruz. Bunun için aşağıdaki gibi bir flake dosyası oluşturabiliriz.

Burada bir çok şey tanıdık zaten tek fark **in** bloğundaki `devShells.<system>.default` yapısı. Bu yapının içine gerekli paketleri yazıyoruz. Dikkat ederseniz `node2nix` paketini de ekledim. Bu paketin amacı nodejs paketlerini nix paketlerine dönüştürmek. Detaylar için [Github sayfasını](https://github.com/svanderburg/node2nix) ziyaret edebilirsiniz. Ayrıca Javascript development ortamı için [resmi dokümanları](https://nixos.org/manual/nixpkgs/stable/#language-javascript) da kesinlikle ziyaret edin. Dotnet için de yine [resmi dokümanlara](https://nixos.org/manual/nixpkgs/stable/#dotnet) bi göz atmanızı tavsiye ederim.


```nix
{
  description = "Dotnet çalışma ortamım";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    overlays = [
        (final: prev: rec {
          nodejs = prev.nodejs_18;
          # nodejs paketlerinden birini yüklüyoruz
          pnpm = prev.nodePackages.pnpm;
          # yarn'ı nodejs ile uyumlu yüklüyoruz
          yarn = (prev.yarn.override { inherit nodejs; });
        })
      ];

    pkgs = import nixpkgs {inherit system overlays;};


  in {
     devShells.${system}.default = pkgs.mkShell {
                packages = with pkgs;
                        [
                          dotnet-sdk_8
                          # https://github.com/svanderburg/node2nix
                          # npm yerine bunu kullanmak özellikle nix paketi oluşturulacaksa daha efektif
                          node2nix
                          nodejs
                          pnpm
                          yarn
                        ];
                };
  };
}

```

Asp.net core ile proje oluşturduğumuz klasörün root dizinine bu flake dosyasını koyup `nix develop` komutunu çalıştırdığımızda ilgili paketler yüklenecek. Kurulum bittiğinde de bizi otomatik olarak terminal bu araçların kurulu olduğu bir terminal olacak. Eğer terminalde `which dotnet` komutunu çalıştırırsak /nix/store/ ile başlayan bir dizin göreceğiz. Başka bir terminalde aynı komutu test ettiğinizde eğer nix paket yöneticisi dışında dotnet yüklediysek onun adresini göreceğiz, yüklemediysek boş dönecektir. Herhangi bir terminalde proje dizinideyken `nix develop` komutunu çalıştırırsak  terminalimiz projemizin bütün bağımlılıklarının yüklenmiş olduğu bir terminale dönüşecektir. 


Terminalde alttaki testleri yaparak işlemin doğru yapıldığından emin olabiliriz.

```bash
node --version
# v18.19.1

dotnet --version
# 8.0.101

npm --version
# 10.2.4


which node
# /nix/store/1ihd9lyhn8q73n9s3iaxbilx4mn4nc5b-nodejs-18.19.1/bin/node
```

Birden fazla sistem için alttaki gibi bir yapı kullanabilirsiniz.

```nix
{
  description = "Dotnet çalışma ortamım"
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs; [
          dotnet-sdk_7
        ];
      };
    });
  };
}

```

mkshell fonksiyonunu [resmi repo'daki adresinden](https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/mkshell/default.nix) inceleyecek olursak alttaki gibi bir yapı göreceğiz. Üstte yaptığımız örnekte doğrudan development ortamının ihtiyacı olan paketleri belirledik. Alttaki listede gördüğümüz input'lar ise bu paketlerin input'larından development ortamının ihtiyacı olan paketleri belirlemek için kullanılıyor.  


```nix
{ lib, stdenv, buildEnv }:

# A special kind of derivation that is only meant to be consumed by the
# nix-shell.
{ name ? "nix-shell"
, # a list of packages to add to the shell environment
  packages ? [ ]
, # propagate all the inputs from the given derivations
  inputsFrom ? [ ]
, buildInputs ? [ ]
, nativeBuildInputs ? [ ]
, propagatedBuildInputs ? [ ]
, propagatedNativeBuildInputs ? [ ]
, ...
}@attrs:

```
Örneğin daha önceki uygulamalarımızda kullandığımız message uygulamamızı kullanarak mevzuyu anlamaya çalışalım. 

Bu C diliyle yazılmış uygulamadan derivative oluşturacak message.nix adında aynı dizinde bir dosya oluşturalım.

```nix
{pkgs}:
        pkgs.stdenv.mkDerivation (finalAttrs: rec{
              name = "message";
              version = "v3.0";

              src = builtins.fetchTarball {
                        url = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${version}.tar.gz";
                        sha256 = "sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";
                    };

              buildInputs = [ pkgs.gcc ];
              nativeBuildInputs = [ pkgs.autoconf pkgs.libtool pkgs.makeWrapper ];
              buildPhase = "gcc -o message ${src}/message.c";
              installPhase = "mkdir -p $out/bin; install -t $out/bin message";

              meta = with pkgs.lib; {
                    description = "message uygulamsı";
                    license = licenses.mit;
                    version =  "${version}";
                };
        })
```
Amacımız hem derivative oluşturmak hem de development ortamında ihtiyacım olan paketlerin bir kısmını da bu  derivative'in input'larından belirlemek. Bunun için alttaki gibi bir flake yazıyoruz.

```nix
{
  description = "Message uygulaması development ortamı";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {inherit system;};

    packages.${system}.default = pkgs.callPackage ./message.nix {pkgs = pkgs;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [dotnet-sdk_7];
      inputsFrom = [packages.${system}.default];
      nativeBuildInputs = [packages.${system}.default];
    };

    packages = packages;
  };
}
```
Dikkat ederseniz development ortamımız için doğrudan belirlediğimiz paket sadece dotnet-sdk_7 oldu. Diğer paketleri ise `inputsFrom` ve `nativeBuildInputs` ile `message.nix` dosyasından alıyoruz. Bu sayede `nix develop` komutu ile development ortamımızı oluşturduğumuzda `message.nix` dosyasında belirlediğimiz paketler de otomatik olarak yüklenecek. Test etmek amacıyla `nix develop` komutu çalıştırıp terminalde gcc komutunu çalıştırırsak onunda yüklendiğini göreceğiz. Ayrıca yazdığımız uygulamayı da test edebiliriz. Ayrıca istersek `nix run .#`  komutu ile yazdığımız uygulamayı da test edebiliriz.

Aslında bu konu belki de Nix paket yöneticisi için paket yazmayı düşünen developer'lar için  daha fazla vakit ayırmaları gereken bir konu.

- Farklı programlama dillerini içeren development ortamları oluşturmak için template'ler için güzel bir [Github reposu](https://github.com/the-nix-way/dev-templates)
- Bir çok programlama dilini içeren örnek development ortamları. Örnek uygulamalar da mevcut. [NixOs resmi repos'undan](https://github.com/NixOS/templates) inceleyebilirsiniz
- Verloper'lar için faydalı bir derleme olmuş. Genel anlamda resmi dokümanların örneklerle anlatılmış bir özeti gibi. [Şu linkten](https://ryantm.github.io/nixpkgs/languages-frameworks/dotnet/#dotnet) inceleyebilirsiniz. Soldaki menüden ilgilendiğiniz dili seçmelisiniz

## Developer Ortamları için Nix Tabanlı Diğer Araçlar

Developer ortamlarınız için bu işe daha fazla odaklanmış, daha profesyonel ve daha fazla özellik sunan bir çok araç mevcut. Bunlardan bazılarını altta listeledim. Özellikle birden fazla kişiyle çalışıyorsanız ve herkesin doğrudan NixOs veya Nix paket yöneticisi le muhatap olmasını da istemiyorsanız bu araçları kullanmanızı tavsiye ederim. Hatta bir çok yerde dev ortamları için developer'ların alttaki araçları nix develop komutu yerine tercih ettiklerini okudum.  

- [devbox](https://github.com/jetpack-io/devbox): Aralarında en çok kullanılan ve en çok yıldız alan proje bu. İncelemenizi kesinlikle tavsiye ederim. Dockerhub benzeri [nixhub](https://www.nixhub.io) adında  bir paket deposu var. Burada arama yapabiliyorsunuz. Go dili ile yazılmış  bir cli'ı var. Quickstart için [şu sayfayı](https://www.jetpack.io/devbox/docs/quickstart/) ziyaret edebilirsiniz.

- [devshell](https://numtide.github.io/devshell/) 

- [devpacks](https://nixpacks.com/docs)

- [devenv](https://devenv.sh/)

## Nix Profile ile Kalıcı Profil Oluşturmak

Daha önce "nix profile" komutunu görmüştük. Temelde `niz shell` komutu geçici kurulum yaparken `nix profile` ise kalıcı kurulum yapar demiştik. Yukarıda gördüğümüz `nix develop` ise proje bazlı kurulum yapıyordu. Ancak `nix profile` komutu incelediğimiz yazımızda declarative bir kullanımı yoktu. Ancak `nix profile` komutu ile de declarative bir şekilde kalıcı bir profile oluşturabiliriz. Böylece sistemimizi kurduktan sonra bütün uygulama kurulumlarını tek bir yerden yönetebiliriz.  

Basit bir örnekle başlayalım. Alttaki kodları flake.nix adında bir doya oluşturup içine kopyalayalım.  



```nix
{
  description = "Murat Cabuk Profile";

  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    };

  outputs = { self, nixpkgs, }:
        {
        packages.x86_64-linux.default = let
           system = "x86_64-linux";
           pkgs = import nixpkgs {inherit system;};
           # pkgs = nixpkgs.legacyPackages."x86_64-linux";
        in pkgs.buildEnv {
                name = "murat-cabuk-profile";
                paths = with pkgs; [
                                    ffmpeg
                                    jq.override { name = "pjq"; }
                                    vim
                                    ];
                pathsToLink = [ "/share/man" "/share/doc" "/share/info" "/bin" "/etc" ];
                extraOutputsToInstall = [ "man" "doc" "info" ];
                postBuild = ''
                                echo işleme tamam >> log.txt
                            '';
                        };


        };
}

```

Bu flake dosyasının olduğu dizinde `nix profile install .` komutunu çalıştırdığımızda eklediğimiz uygulamalar kurulacaktır. Eğer uygulamada bir güncelleme yaparsak `nix profile upgrade <profile_index>` komutu ile güncelleyebiliriz. Profile indeksini almak için `nix profile list` komutu ile öğrenebiliriz. 

Burada artık overlay ve override gibi konulara girmiyorum eski yazılardan bakılabilir. Ayrıca `nix profile` komutu ile ilgili daha fazla bilgi için [resmi dokümanları](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-profile.html) inceleyebilirsiniz.


Daha karmaşık örnekler için de NixOs [resmi dokümanlarını](https://nixos.org/manual/nixpkgs/stable/#sec-declarative-package-management) da okuyabilirsiniz. 

Evet buraya kadar gördüklerimizde NixOS'a hiç ihtiyacımız olmadı. Zaten ilk yazılarda da belirttiğim gibi Nix temelde distro bağımsız bir paket yöneticisi yani temel amacı aslında bu. NixOs ise Nix Dilinin ve paket yöneticisinin yetenekleri üzerine inşa edilmiş bir Linux dağıtımı. 

Bir çok developer üstteki dev ortamları oluşturma aracını NixOS'a hiç bulaşmadan hatta hiç Nix dilini öğrenmeden kullanıyor. Yada bir çok kullanıcı NixOs'u sadece Konfigürasyon yapacak kadar öğreniyor. Yani Nix dilinden bile habersiz NixOs kullanan dolusuyla son kullanıcı var.


Tabi bizim amacımız Nix dilini de paket yöneticisini de ve NixOs'u da mümkün oldukça hakkını vererek öğrenebilmek. Tabi bütün bunlar sadece bu yazıları okuyarak olmayacaktır. Ancak size ciddi bir başlangıç yapmanızı sağlayacaktır.

Sonraki yazımızda NixOs'a geçiş yapacağız ancak ilk etapta nasıl kurulur konusuna girmeyeceğiz. Çünkü ilk kurulum için aslında normal herhangi bir Linux dağıtımından farklı kurulmuyor. Ancak elimizde bir Nix konfigürasyonu varsa durum biraz değişiyor. Eğer elimizde konfigürasyon dosyaları varsa bu durumda sadece flake.nix dosyasını da içeren root dizinin vermemiz kurulum için yeterli olacaktır.

İlk etapta Youtube'dan bulacağınız herhangi bir kurulum video'su ile  sisteminizi kurabilirsiniz. MEvzumuz ilk etapta zaten kurulum detayları ile ilgilenmek değil. Ancak elimizde orta halli bir NixOs konfigürasyonu oluştuğunda artık sıfırdan manuel kurulu yerine declarative yöntemle kurulum yapacağız.


## Kaynaklar
- https://nixos.wiki/wiki/Development_environment_with_nix-shell
- https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-mkShell
- https://nixos.wiki/wiki/Nixpkgs/Create_and_debug_packages
- https://github.com/nix-community/nixpkgs-fmt
- https://blog.ysndr.de/posts/guides/2021-12-01-nix-shells/
- https://github.com/the-nix-way/dev-templates
- https://discourse.nixos.org/t/problem-combining-multiple-dotnet-sdks-in-usable-flake/32431
- https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/dotnet.section.md
- https://nixos.org/manual/nixpkgs/stable/#sec-building-environment
- https://ianthehenry.com/posts/how-to-learn-nix/how-to-learn-nixpkgs/
- https://jade.fyi/blog/flakes-arent-real/