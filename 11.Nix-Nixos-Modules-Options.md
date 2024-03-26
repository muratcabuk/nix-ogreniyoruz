## NixOs Module ve Option Kullanımı (Nix Öğreniyoruz 11)

Bu yazı büyük ihtimal serinin en uzun yazısı olacak. Konuyu büyük ihtimal tek seferde okuyup bitirmek isteyeceksiniz. Belki en çok git gel yapacağınız yazı da bu olacak.


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


Bu yazıda ilk yazılarımızda sıkça kullandığımız `nix repl` aracını bol bol kullanacağız. Module yazarken sıkça yapılan hataları inceleyeceğiz. Bu yazıda amacımız doğrudan çalışabilir module yazmak değil. ONu da bir sonraki yazımızda yapacağız. Yani Orta halli bir NixOs konfigürasyonu yapacağız. Orada ihtiyacımız olan bir kaç modülü de yazmış olacağız.

İlk yazılarımızda `nix repl` aracını sık sık kullanmıştık. Ancak doğrudan bu sayfaya gelenler veya unutmuş olanlar için ufak bir bahsedelim.

Terminalden `nix repl` dediğimizde cli açılacaktır. Burada amaç developer'lar için kodlarını tet edebilecekleri  hatalarını görebilecekleri bir araç sunmak. `:?` komutu ile alttaki yardım metnine ulaşabilirsiniz.


```text
The following commands are available:

  <expr>                       Evaluate and print expression
  <x> = <expr>                 Bind expression to variable
  :a, :add <expr>              Add attributes from resulting set to scope
  :b <expr>                    Build a derivation
  :bl <expr>                   Build a derivation, creating GC roots in the
                               working directory
  :e, :edit <expr>             Open package or function in $EDITOR
  :i <expr>                    Build derivation, then install result into
                               current profile
  :l, :load <path>             Load Nix expression and add it to scope
  :lf, :load-flake <ref>       Load Nix flake and add it to scope
  :p, :print <expr>            Evaluate and print expression recursively
  :q, :quit                    Exit nix-repl
  :r, :reload                  Reload all files
  :sh <expr>                   Build dependencies of derivation, then start
                               nix-shell
  :t <expr>                    Describe result of evaluation
  :u <expr>                    Build derivation, then start nix-shell
  :doc <expr>                  Show documentation of a builtin function
  :log <expr>                  Show logs for a derivation
  :te, :trace-enable [bool]    Enable, disable or toggle showing traces for
                               errors
  :?, :help                    Brings up this help menu
```

Nix dosyalarına yazdığımız expression'ları doğrudan repl içine yazıp çağırabiliriz ya da bir nix dosyasını load (:l) komutu ile repl içine yükleyebiliriz. Oluşan verileri de print (:p) komutu ile görebiliriz.

```bash
nix-repl> a = [1 2 3 4]

nix-repl> a
#[ 1 2 3 4 ]

nix-repl> :p a
#[ 1 2 3 4 ]

nix-repl> b = {a=1;b=2;c=3;}

nix-repl> :p b
#{ a = 1; b = 2; c = 3; }

nix-repl> func = a: b: a + b   

nix-repl> result = func 1 2

nix-repl> :p result 
#3
```
Biraz kurcalayarak rahatlıkla uzmanı olabilirsiniz. Ancak tabi Nix dilinin uzmanı olmak biraz vakit alabilir. Bunun için ilk yazılarımızı okuyabilirsiniz. Repl hakkında daha fazla bilgi almak için [şu sayfayı](https://aldoborrero.com/posts/2022/12/02/learn-how-to-use-the-nix-repl-effectively/) da ziyaret edebilirsiniz.

Diğer bir yararlı araç da  `nix eval` komutu. Bu komut ile bir nix dosyasını çalıştırabilir ve sonucunu görebilirsiniz. 

```bash
nix eval --raw nixpkgs#lib.version
#24.05.20240223.48b75eb%                                                                 


nix eval --raw nixpkgs#hello
#/nix/store/63l345l7dgcfz789w1y93j1540czafqh-hello-2.12.1%                               


nix eval --write-to ./out --expr '{ foo = "bar"; subdir.bla = "123"; }'
cat ./out/foo
# bar
cat ./out/subdir/bla
#123

```
Module yapısı ile ilgili tüm gerekenler lib kütüphanesi içinde yer alıyor. Resmi sayfasında lib klasöründeki [default.nix](https://github.com/NixOS/nixpkgs/blob/master/lib/default.nix) dosyasına bakacak olursanız alttaki satıları görebilirsiniz. Modules dosyasında modüllerle ilgili fonksiyonlar yer alırken options dosyasında ise option'larla ilgili fonksiyonlar yer alır. Tabi ben böyle yazınca mantıklı geliyor :) zaten öyle olmamalı mıydı? diyebilirsiniz. Ancak kod yazarken özellikle bir module yazarken bu ayrımı yapmak bazen zor olabiliyor. Kafanız karıştığında dediğimi hatırlarsınız.

```nix

# kısaltıldı

    # module system
    modules = callLibs ./modules.nix;
    options = callLibs ./options.nix;
    types = callLibs ./types.nix;

# kısaltıldı
```

Bazen hata bulmak veya ne yapacağınızı anlayabilmek için bu dosyalara bakmamız gerekebilir.

Modules dosyasında bir çok fonksiyon bulunuyor ancak bizim  çok iyi bilmemiz gerekenler kalın olarak işaretlediklerim.

| | |
|-|-|
|**evalModules** |filterOverrides|
|filterOverrides'|fixMergeModules|
|fixupOptionType  # should be private?|
|importJSON|importTOML|
|mergeDefinitions|mergeAttrDefinitionsWithPrio|
|mergeOptionDecls |**mkAfter**|
|mkAliasAndWrapDefinitions|mkAliasAndWrapDefsWithPriority|
|mkAliasDefinitions|mkAliasIfDef|
|mkAliasOptionModule|mkAliasOptionModuleMD|
|**mkAssert**|**mkBefore**|
|mkChangedOptionModule|**mkDefault**|
|mkDerivedConfig|mkFixStrictness|
|**mkForce**|**mkIf**|
|mkImageMediaOverride|**mkMerge**|
|mkMergedOptionModule|mkOptionDefault|
|**mkOrder**|**mkOverride**|
|mkRemovedOptionModule|mkRenamedOptionModule|
|mkRenamedOptionModuleWith|mkVMOverride|
|setDefaultModuleLocation|sortProperties;|
|||


Options Doyasına bakacak olursak alttaki gibi bir liste ile karşılaşıyoruz. Burada da yine iyi bilmemiz gerekenleri kalın olarak işaretledim.


|||
|-|-|
|**isOption**|**mkOption**|
|**mkEnableOption**|**mkPackageOption**|
|mkPackageOptionMD|**mergeDefaultOption**|
|mergeOneOption|mergeUniqueOption|
|mergeEqualOption|getValues|
|getFiles|optionAttrSetToDocList|
|scrubOptionValue|renderOptionValue|
|literalExpression|mdDoc|
|literalMD|showOption|
|showFiles|showDefs|

types dosyasında ise alttaki tiplerin tanımın görebiliriz.


|||
|-|-|
|bool|true, false|
|boolByOr|eğer iki tanımlama da true ise sonuç true'dur.|
|path|path tanımlamak için kullanılır. eğer paket tanımı/adresi kullanılacaksa, yani amaç bir paketse package tipi kullanılmalı|
|package|bir derivation veya flake içeren path|
|pathInStore|nix store içeren bir path|
|anything|tip bilinmediğinde kullanılabilir|
|raw|eğer tip checking, merging veya nested evaluation yapmıyorsa kullanılabilir.|
|pkgs|paket seti|
|int|tam sayı|
|ints|tam sayı seti|
|ints.positive|pozitif tam sayılar|
|port|port numarası|
|float|noktalı sayı|
|number|float veya int olabilir|
|str|metin ifadesi|
|lines|satırlardan oluşan string ifade|
|commas|virgül ile birleştirilmiş metinler|
|envVar|iki nokta üst üste (\:) ile birleştirilmiş metinler|
|strmathing|regular expression ile eşleşen metin. Ayrı değerler tekrarlamaz|
|submodule, submoduleWith|bir başka module'u ifade eden tip|
|listOf t|t tipinde liste|
|attrOf t|value değerlerinin tipi t olan set|
|nullOr t|null veya t tipi|
|uniq t|t tipi sadece bir kez ifade edilebilir. Birden fazla değer merge edilemez|
|oneOf [ t1 t2 … ]|tiplerden biri|
|either t1 t2|t1 tipi veya t2 tipi|
|coercedTo from f to|from tipinde bir tip alıp to tipini döndüren bir fonksiyon |


Submodule tipi için bir kaç açıklama yapmamız gerekiyor.


## Custom Type
Bunu için mkOptionType fonksiyonu kullanılır. [Resmi dokümanlarında](https://nixos.org/manual/nixos/stable/#sec-option-types-custom) da denildiği gibi custom yip yazmak biraz çetrefilli bir iş. Ben de zaten giriş mahiyetinde bir şeyler yazacağım.

Amacımız kullanacağımız option ve modüllerde geçen terim ve tabirlere de aşina olmak. 

Gerekli parametreler

- **name** : Tipin adı
- **description**: Tipin açıklaması
- **check**: Tipin için type check fonksiyonu. True ve false döndürmelidir.
- **merge**: Birden fazla değer merge edilirken kullanılacak fonksiyon. Bir tip için birden fazla değer farklı yerlerde atanmış olabilir.  Bunların merge edilirken nasıl birleştirileceğini belirler. Sonuçta nihai bir değer elde etmek için kullanılır. 
- **getSubModules**: Submodule tipleri üretmek için gereklidir.
- **getSubOptions**:  Bütün submodule'lerin option'larına erişmek için kullanılır.
- **substSubModules**: Bir modülü parametre olarak alır ve geriye modülün parametrelerini değiştirerek döndürür.


Özet olarak tipleri kullanırken bu başlıktan çıkartacağımız sonuçlar
- tiplerin türü önemli
- ve tiplerini merge edilmesi gibi bir durum var bu nedenle doğru değerlerle ve öncelikle doğru belirlenerek kullanılmaları gerekiyor.


## Module ve Option Kullanımı


Şimdi örneklerle mevzuyu anlamaya çalışalım. Özellikle belirtmediğim sürece bu yazıda yaptıklarımı Nix kurulu herhangi bir sistemde yapabilirsiniz.


Alttaki gibi basit bir  module (default.nix) yazalım. 

```nix
# default.nix
 { lib, ... }: {

    options = {
      scripts.output = lib.mkOption {
        type = lib.types.lines;
      };
    };

 }
```

Daha sonra yazdığımız modülünü doğrulama için evaluate fonksiyonunda geçirelim. Bu fonksiyon  Nix dili içinde bulunan ve modül dosyalarını değerlendirmek için kullanılan bir fonksiyondur. Bu fonksiyon, bir veya birden fazla Nix modül dosyasını yükler, değerlendirir ve sonuçları birleştirir.


```nix
# eval.nix
let
  system = "x86_64-linux";
  pkgs = import <nixpkgs> {inherit system; config = {allowUnfree = true;}; overlays = []; };
in
pkgs.lib.evalModules {
  modules = [
    ./default.nix
  ];
}
```


evalModules fonksiyonunun içeriğini görmek için repl içinde alttaki komutları çalıştırabilirsiniz. Görüldüğü üzere tek zorunlu parametre modules. Diğer parametreler ise opsiyonel.

```bash
# nix paket koleksiyonunu indiriyoruz
:l <nixpkgs> 

# evalModules içerğini editleme modunda açıyoruz.
# çıkmak için ctrl+q yapmalısınız.
:e lib.evalModules

# kısaltıldı
# evalModules = evalModulesArgs@
#                 { modules
#                 , prefix ? []
#                 , specialArgs ? {}
#                 , class ? null
#                 , args ? {}
#                 , check ? true
#                 }:
#     let
#       withWarnings = x:
# kısaltıldı

```

Şimdi kodumuzu test edelim.


```bash
nix eval -f eval.nix

# error: The option `scripts.output' is used but not defined.

```
Sonuç olarak bir option tanımladığımızı ancak kullanmadığımız belirten bir hata aldık.

Aynı testi repl içinde de yapabiliriz.

```bash
myModule = import ./eval.nix
:p myModule
# error: The option `scripts.output' is used but not defined.»; }; }; }; type = «repeated»; }
```

Benzer bi hata aldık.

O zaman config bloğumuzu tanımlayalım. default.nix dosyamızı alttaki gibi değiştirelim.


```nix
# default.nix
 { lib, ... }: {

    options = {
      scripts.output = lib.mkOption {
        type = lib.types.lines;
      };
    };

    config = {
     scripts.output = 42;
    };
 }
```

Şimdi tekrar test edelim.

```bash
nix eval -f eval.nix

# error: A definition for option `scripts.output' is not of type `strings concatenated with "\n"'. Definition values:
# - In `/home/.../.../default.nix': 42
```
Evet gayet mantıklı bir hata aldık. Çünkü bizim tanımladığımız tip lines iken biz bir sayı tanımladık.


```nix
# default.nix
 { lib, ... }: {

    options = {
      scripts.output = lib.mkOption {
        type = lib.types.lines;
      };
    };

    config = {
     scripts.output = "wget https://www.google.com -O /etc/test.txt";
    };
 }
```

Şimdi test ettiğimizde ise  alttaki gibi bir durum gördük. Bu durum belki siz baktığınızda düzelmiş olabilir. Bu yazı dizisinde tamamen yeni teknolojiye uygun komutların göreceğimizden bahsetmiştim ancak ilk kez burada tıkandık. Temel sebebi ise [Nix Github sayfasından](https://github.com/NixOS/nix/issues/7701) da takip edebileceğiniz üzere halen bir çok komutun stabil olmaması. Yani bu vakte kadar kullanımda bir problem yaşamadık ki sadece ben değil internette de görebileceğiniz üzere birçok kişi son sürüm komutları kullanıyor. Zaten bu yaşadığımız durumda çalışmasına engel bir durum değil. `evalModule` fonksiyonu bildiğimiz üzere  gerçekten kodları çalıştırmıyor. Bu nedenle özel durumları yönetmek üzere dizayn edilmemiş. Ancak burada yaşanan durumu `nix eval` komutu handle etmeliydi ancak o da en azından bu durumu yönetemiyor. Bu nedenle eski komutlardan biri olan `nix-instantiate` komutunu kullanarak test edebiliriz. 

```bash
nix eval -f eval.nix

# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
# trace: warning: Use `stdenv.tests` instead. `passthru` is a `mkDerivation` detail.
```

`nix-instantiate` ile test etmek  için de alttaki komutu kullanabiliriz. Komut ile eval.nix dosyasını config bloğunun ürettiği sonuçları çağırabiliyoruz.

```bash
nix-instantiate --eval eval.nix -A config.scripts.output
# "wget https://www.google.com -O /etc/test.txt"
```

Şimdi paket üreten bir option tanımlayalım. Amacımız nixpkgs koleksiyonundan bir paketi kullanarak bir shell script'i yazıp bunu paket olarak option olarak modülle ayarlamak. Bunu yaparken de script'i daha önce oluşturduğumuz `scripts.output` option'ından alacağız. 

Bu işlemleri yapabilmemiz için default.nix dosyamıza  pkgs ve config parametrelerini eklememiz gerekiyor. Hatırlarsanız yukarıda aynı modül içinde dahi olsalar bir option'a doğrudan değil merkezi config setinden erişmemiz gerekiyor demiştik. `script.paket` option değerini atadığımız yerde `config.scripts.output` değerini kullandığımıza dikkat edin.


```nix
# default.nix

{ lib, pkgs,config,... }: {

    options = {
      scripts.paket = lib.mkOption {
        type = lib.types.lines;
      };

       scripts.output = lib.mkOption {
         type = lib.types.package;
       };

    };

    config = {
      scripts.output = "wget https://www.google.com -O /etc/test.txt";

      scripts.paket = pkgs.writeShellApplication {
                 name = "create-etc";
                 runtimeInputs = with pkgs; [ wget ];
                 text = config.scripts.output;
     };

    };
 }
```

Eval.nix dosyamızı da alttaki gibi değiştirelim. Modülümüz artık  pkgs ve config parametrelerini de istiyor. Ancak biz sadece pkgs parametresini hazırlasak yeterli olacaktır. Çünkü config ve lib parametresi modülün içine modül eko-sistemi/kurgusu tarafından  otomatik olarak ekleniyor. 

```nix
#eval.nix

let
  
  system = "x86_64-linux";
  pkgs = import <nixpkgs> {inherit system; config = {allowUnfree = true;}; overlays = []; };

  

in
  pkgs.lib.evalModules {

    modules = [
              # alttaki satırı kapatıp specialArg'ı kullandık. Burada aslında anonymous foksiyon açlıştırıp bir modül döndürüyoruz  aslında.
              # bu modülde bağlı olduğu modün bir argümanını dolduruyor.
              # specialArgs ise doğrudan modülün argumanlarını ekliyor.
              #({ config, ... }: { config._module.args = { pkgs = pkgs; }; })
               ./default.nix
              ];
                specialArgs = {pkgs = pkgs; };
          
  }


```



```bash
nix-instantiate --eval eval.nix -A config.scripts.paket 

# sonuç olarak elimizde bir paketin attribute'ları listelenmiş oldu.
# { __ignoreNulls = true; __structuredAttrs = false; all = <CODE>; allowSubstitutes = true; args = <CODE>; buildCommand = <CODE>; buildInputs = <CODE>; builder = <CODE>; checkPhase = <CODE>; cmakeFlags = <CODE>; configureFlags = <CODE>; depsBuildBuild = <CODE>; depsBuildBuildPropagated = <CODE>;
```

## Bir Modülü Başka Bir Modüle Eklemek

Bir modül içine başka modül de ekleyebiliriz. Örneğin alttaki gibi bir modül (my-module.nix) yazalım. Config bloğu içinde `scripts.output` ile default altındaki config'de de yaptığımız atamanın ayn ısını yaptık. Yani aynı konfigürasyon farklı modüllerde tekrar yapıldı yani. 

```nix
# my-module.nix
{ lib, pkgs,config,... }: {

    options = {
        
      apps.message = lib.mkOption {
        type = lib.types.package;
      };

    };

    config = {
              apps.message = pkgs.writeShellApplication {
                                      name = "hello-app";
                                      runtimeInputs = with pkgs; [ cowsay ];
                                      text = ''
                                                cowsay ${config.scripts.output}
                                              '';
                    };
              scripts.output = ''
                      sample script
                      '';
                    };
              };
}
```

Bu modülü default.nix dosyasına imports listesi ekleyebiliriz ekleyelim.

```nix
{ lib, pkgs,config,... }:{
    imports = [
      ./my-module.nix
    ];

    options = {
      scripts.output = lib.mkOption {
          type = lib.types.lines;
      };
  
      scripts.paket = lib.mkOption {
          type = lib.types.package;
      };

    };

    config = {
      scripts.output = ''
                      wget https://www.google.com -O /etc/test.txt
                      '';

      scripts.paket = pkgs.writeShellApplication {
                                      name = "create-etc";
                                      runtimeInputs = with pkgs; [ wget ];
                                      text = config.scripts.output;
      };

  };
}

```
## Submodule Kullanımı


Bir tip tanımı için let ve in bloklarını kullanmamız gerekiyor. Burada bir submodule tipi oluşturduk ancak bunu hazır tipleri kullanarak yaptık. Submodule'den kasıt bir önceki örnekte gördüğümüz gibi bir modülü başka bir modülün içine eklemek değildir. Burada aslında bir module ve içindeki option'ları birleştiren bir tip tanımı (subModuleType) yapmış oluyoruz.

İlginç olan bu tipi kullanarak oluşturduğumuz mymodules option'unun tipinin daha önce oluşturduğumuz submodule tipinde liste tutuyor olması `lib.types.listOf subModuleType;`.




```nix
# default.nix
{ lib, pkgs,config,... }:

let

      # bir submodule tipi oluşturduk ve içerisine message adında bir opsiyon ekledik
      subModuleType = lib.types.submodule {
          options = {
            message = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
          };
      };
in
{
    imports = [
      ./my-module.nix
    ];

    options = {
      scripts.output = lib.mkOption {
          type = lib.types.lines;
      };
  
      scripts.paket = lib.mkOption {
          type = lib.types.package;
      };

    
      mymodules = lib.mkOption {
        # dikkat edilirse subModuleType submodule listesi isteyen bir tip tanımımız var
        type = lib.types.listOf subModuleType;
      };

    };

    config = {
      scripts.output = ''
                      wget https://www.google.com -O /etc/test.txt
                      '';

      scripts.paket = pkgs.writeShellApplication {
                                      name = "create-etc";
                                      runtimeInputs = with pkgs; [ wget ];
                                      text = config.scripts.output;
      };

    mymodules = [
      {message = "Hello World!";}
      {message = "how are you?";}
    ];

    };
}

```
Şimdi bu modülü test edelim. İki eleman eklediğimiz için sonuçta iki elemanın da döndüğünü göreceğiz.

```bash
nix-instantiate --eval eval.nix -A config.mymodules
# [ <CODE> <CODE> ]
```
Bu arada iç içe submodule tanımlamak da mümkün. Detaylarını [şu sayfadan](https://nix.dev/tutorials/module-system/module-system.html#nested-submodules) bakabilirsiniz.


## mkIf, mkMerge, mkForce, mkDefault, mkOverride Kullanımı

Belki aklımıza neden `if else` yapısı kullanmıyoruz da mkIf fonksiyonu kullanıyoruz sorusu aklımıza gelebilir. Bunun sebebi normal `if else` kullanımının bizi recursion hatasına götüreceği. Bu yüzden mkIf fonksiyonu module kullanımı için yazılmış. Aşağıda mkIf ile yapacağımız örnekleri isterseniz `if else` yapısı ile de yapabilir ve sonucu görebilirsiniz.  

`mkIf` fonksiyonunun kullanımı çok basit.

```nix
mkIf 1=1 "yes"
# veya diğer örnek

mkIf !(1=2) "no"
```

Normalde mhIfElse gibi bir fonksiyon yok. Ancak forumlarda araştırırsanız sıklıkla alttaki gibi bir yapıyı görebilirsiniz. Bu tarz bir fonksiyon yazarak if else yapısı oluşturabilirsiniz. 

```nix
mkIfElse = p: yes: no: mkMerge [
  (mkIf p yes)
  (mkIf (!p) no)
];
```

mkMerge farklı konfigürasyonları birleştirmek için kullanılır. Örneğin alttaki gibi bir kullanım yapabiliriz. `mkIf` ile bir koşula bağlı konfigürasyon başka bir grup konfigürasyonla birleştirilebilir.  

```nix
config = mkMerge
  [ # Unconditional stuff.
    { environment.systemPackages = [ ... ];
    }
    # Conditional stuff.
    (mkIf config.services.bla.enable {
      environment.systemPackages = [ ... ];
    })
  ];
```


`my-module.nix` dosyamızı çalım ve alttaki değişiklikleri yapalım.


```nix

{ lib, pkgs, config,... }: {

    options = {
        
      apps.message.paket = lib.mkOption {
        type = lib.types.package;
      };

      apps.message.iswebsiteBing = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };


    };

    config = lib.mkMerge [ {
                              apps.message.paket = pkgs.writeShellApplication {
                                      name = "hello-app";
                                      runtimeInputs = with pkgs; [ cowsay ];
                                      text = ''
                                                cowsay ${config.scripts.output}
                                              '';
                                  };
                              apps.message.iswebsiteBing = true;
                        }

                        
                        (lib.mkIf config.apps.message.iswebsiteBing {
                                              scripts.output = ''
                                                          wget https://www.bing.com -O /etc/test.txt
                                                                            ''; })
                    ];
}

```

Önceki versiyonunda hatırlarsanız zaten default.nix modülümüzde tanımlandığımız ve ataması yapılmış `scripts.output` opiton'ınını alttaki gibi `my-module.nix` dosyasında tekrar tanımlamıştık.

```nix
scripts.output = ''
                wget https://www.google.com -O /etc/test.txt
                '';
```
Yeni versiyonda ise `mkIf` fonksiyonu ile `apps.message.iswebsiteBing` option'ına bağlı olarak `scripts.output` option'ını tekrar tanımladık. Config bloğunu artık mkMerge ile farklı kombinasyonları merge (birleştirecek) şekilde tanımladığımıza dikkat edin.  

Şimdi bu değişiklikten sonra tekrar test edelim.


```bash
nix-instantiate --eval eval.nix -A config.scripts.output
# "wget https://www.bing.com -O /etc/test.txt\n\nwget https://www.google.com -O /etc/test.txt\n"
```
Sonuçta bir gariplik olduğunu görebiliyoruz. Hem `default.nix` hem de `my-module.nix` dosyalarında atadığımız değerleri birleştirerek bize döndürdü. Eğer bizim için `my-module.nix` modülündeki atama diğer bütün modüllerdeki atamalardan önemliyse o zaman mkForce fonksiyonunu kullanmalıyız. Kodu alttaki gibi düzenliyoruz.

```nix
                        (lib.mkIf config.apps.message.iswebsiteBing {
                                              scripts.output = lib.mkForce ''
                                                          wget https://www.bing.com -O /etc/test.txt
                                                                            ''; })
```
Tekrar test ettiğimizde artık sonucun düzeldiğini görebiliyoruz.

```nix
nix-instantiate --eval eval.nix -A config.scripts.output --show-trace
# "wget https://www.bing.com -O /etc/test.txt\n"
```

`mkForce` fonksiyonunun nasıl çalıştığını anlarsak diğerlerini de çözmüş olacağız.  Bunun için `lib.modules.nix` dosyasına bir göz atalım. Kod bloğuna [şu linkten](https://github.com/NixOS/nixpkgs/blob/8bee50f7085e913db0f1809f6287d4d84aef5af0/lib/modules.nix#L999C2-L1037C26) ulaşabilirsiniz.

```nix
# modules.nix

# Kısaltıldı
  mkOverride = priority: content:
    { _type = "override";
      inherit priority content;
    };

  mkOptionDefault = mkOverride 1500; # priority of option defaults
  mkDefault = mkOverride 1000; # used in config sections of non-user modules to set a default
  defaultOverridePriority = 100;
  mkImageMediaOverride = mkOverride 60; # image media profiles can be derived by inclusion into host config, hence needing to override host config, but do allow user to mkForce
  mkForce = mkOverride 50;
  mkVMOverride = mkOverride 10; # used by ‘nixos-rebuild build-vm’

  defaultPriority = lib.warnIf (lib.isInOldestRelease 2305) "lib.modules.defaultPriority is deprecated, please use lib.modules.defaultOverridePriority instead." defaultOverridePriority;

  mkFixStrictness = lib.warn "lib.mkFixStrictness has no effect and will be removed. It returns its argument unmodified, so you can just remove any calls." id;

  mkOrder = priority: content:
    { _type = "order";
      inherit priority content;
    };

  mkBefore = mkOrder 500;
  defaultOrderPriority = 1000;
  mkAfter = mkOrder 1500;
# Kısaltıldı

```

`mkForce = mkOverride 50;` satırına  dikkat ederseniz mkOverride ile değeri 50 olarak atanmış. Burada düşük değer daha üstte bir değer. `mkDefault = mkOverride 1000;` satırı ile default değerin 1000 olduğunu  görebiliyoruz. Dolayısıyla `mkForce` fonksiyonu ile bir değer atadığımızda bu değer diğer bütün değerlerden öncelikli oluyor. 



Normal şartlarda modülleri import ederken sıralama yapmamıza gerek yoktur. Hatırlarsanız `default.nix` dosyamızda imports diye modüle adreslerinin listesini tutan bir değişkenimiz vardı.Diyelim ki aynı opiton'ın değerini farklı iki modüle değiştiriyor olsun. Bu durumda bu iki module import edildiğinde ikinci import edilen birincideki değeri ezecektir. Ancak **conflict** oluşturan bir durum olursa bunu bizim çözmemiz gerekir.
 

Birde **conflict** durumunu örnekleyelim. Adı`my-module-first.nix` olan bir dosya oluşturalım. içeriği de alttaki gibi olsun. Bu sefer `my-module.nix` içinde oluşturduğumuz ve atamasını ad yaptığımız `apps.message.iswebsiteBing` option'ının değerini bu sefer false olarak ayarladık.

```nix

{ lib, config,... }: {config = { apps.message.iswebsiteBing = false; };}

```
Bu modülü `default.nix` dosyasındaki imports listesine birinci ve diğer modül de ikinci olarak ekleyelim. Yani alttaki gibi olacak.

Olayı bi anlamaya çalışalım. Normalde `default.nix` dosyasında tanımlı olan `scripts.output` option'ı google.com'a giderken biz onu iswebsiteBing option'ı true olursa mkForce fonksiyonunu kullanarak bing.com'a gidecek şekilde `my-module.nix` dosyamızda ayarlamıştık.

Şimdi yeni modülümüzde ise iswebsiteBing option'ı false olarak ayarladık. Bu durumda `default.nix` dosyasında tanımlı olan `scripts.output` option'ı google.com'a gidecek şekilde ayarlanmasını bekliyoruz.



```nix
# default.nix
    imports = [
      ./my-module-first.nix
      ./my-module.nix
    ];

```

Bi test edelim bakalım.

```bash
nix-instantiate --eval eval.nix -A config.scripts.output --show-trace  

# error: The option `apps.message.iswebsiteBing' has conflicting definition values:
#  - In `/home/.../tests/my-module.nix': true
#  - In `/home/.../tests/my-module-first.nix': false
#  Use `lib.mkForce value` or `lib.mkDefault value` to change the priority on any of these definitions.
```

Fakat conflict oluştu ve sebebi de gayet açık. Biri true derken diğeri false diyor. Bu tarz bir durumu mesela lattaki gibi bir kod yazsaydık da yaşayacaktık

```nix
{ lib, config,... }: {config = { apps.message.iswebsiteBing = lib.mkMerge [false true]; };}
```

işte bu tarz bi durumu yönetmek için de mkOverride fonksiyonu kullanılabilir. `my-module-first.nix` dosyasını alttaki gibi değiştirelim.

```nix
{ lib, config,... }: {config = { apps.message.iswebsiteBing = lib.mkOverride 50 false; };}
```

Tekrar test edelim.

```bash
# nix-instantiate --eval eval.nix -A config.scripts.output --show-trace
"wget https://www.google.com -O /etc/test.txt\n"

```
Ve evet sonuç istediğimiz gibi oldu. Yani sonradan yüklenen modülün option değeri daha öncelikli olmasına rağmen onu mkOverride ile ezmiş olduk. Yukarıda göreceğiniz üzere mkForce fonksiyonu önceliği 50 olarak ayarlıyor ancak bir mkOverride ile daha 30 olarak ayarladığımız için sonuçta mkOverride fonksiyonu daha öncelikli oldu.

## mkOrder, mkBefore ve mkAfter Kullanımı

Bazen de bir değer iki farklı yerde atanabilir ancak conflict oluşturmayabilir. Conflict durumları çoğunlukla scalar ve boolean değerlerde olur ki bu da gayet normal. Boolean'a örnek olarak mesela bir şeye hem doğru hem yanlış diyemeyiz. Scalar'a örnek olarak  mesela bir ses seviyesine  hem 50 hem de 100 diyemeyiz. Ama mesela bir isim listesini farklı şekillerde atayabiliriz. Yani her atamada farklı isimler olabilir. Bu durumda conflict oluşmaz. 



Conflict oluşturmayan bu tip  durumlarda bazen sonra eklenen modül öncekini  ezer yada örneğin bir liste ise bunlar birleştirilir ancak yine sonra gelen öncekinden daha önce listeye eklenir.. Ancak bu işimize gelmeyebilir. Yani biz önce eklediğimiz modülün sonrakinden daha öncelikli olmasını isteyebiliriz.

Birde bunun için örnek yapalım.


`my-module.nix` dosyasını alttaki gibi değiştirelim. Str (metin) tiğinde liste tutan bir option ekleyip  daha sonra`apps.message.list = [ "test4" "test5" "test6" ];` şeklinde değerler ekledik.

```nix

{ lib, pkgs, config,... }: {

    options = {
        
      apps.message.paket = lib.mkOption {
        type = lib.types.package;
      };

      apps.message.iswebsiteBing = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };


      apps.message.list = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };


    };

    config = lib.mkMerge [ {
                              apps.message.paket = pkgs.writeShellApplication {
                                      name = "hello-app";
                                      runtimeInputs = with pkgs; [ cowsay ];
                                      text = ''
                                                cowsay ${config.scripts.output}
                                              '';
                                  };
                              apps.message.iswebsiteBing = true;

                              apps.message.list = [ "test4" "test5" "test6" ];


                        }

                        
                        (lib.mkIf config.apps.message.iswebsiteBing {
                                              scripts.output = lib.mkOverride 100 ''
                                                          wget https://www.bing.com -O /etc/test.txt
                                                                            ''; })
                        

                    ];
}

```

`my-module-first.nix` dosyasını da alttaki gibi değiştirdik. 

```nix
{ lib, config,... }: {
  config = { 
    apps.message.iswebsiteBing = lib.mkOverride 50 false; 
    apps.message.list = [ "test1" "test2" "test3" ];
    };
  }
```

`default.nix` dosyasında ise `my-module-first.nix` modülünü `my-module.nix` modülünden önce import etmiştik. Bu haliyle test edelim. Sonu string ve xmp parametreleriyle aldık çünkü bunları koymadığımızda sistem listedeki değerleri hesaplamıyor.

```nix
nix-instantiate --eval eval.nix -A config.apps.message.list --xml --strict

# <?xml version='1.0' encoding='utf-8'?>
# <expr>
#   <list>
#     <string value="test4" />
#     <string value="test5" />
#     <string value="test6" />
#     <string value="test1" />
#     <string value="test2" />
#     <string value="test3" />
#   </list>
# </expr>
```

Görüldüğü üzere sistem sonra eklenen modüldeki değerleri listeye daha önce ekledi mer ederken.Halbuki biz değerleri sıralı istiyorduk diyelim.
Bu durumda `my-module-first.nix` modülünde alttaki gibi  değişiklik yapıyoruz.

```nix
{ lib, config,... }: {
  
  config = { 
    apps.message.iswebsiteBing = lib.mkOverride 50 false; 
    apps.message.list =lib.mkBefore [ "test1" "test2" "test3" ];
    };
  
  }
```

Şimdi test edelim. Evet sonuç istediğimiz gibi oldu.

```nix

nix-instantiate --eval eval.nix -A config.apps.message.list --xml --strict
# <?xml version='1.0' encoding='utf-8'?>
# <expr>
#   <list>
#     <string value="test1" />
#     <string value="test2" />
#     <string value="test3" />
#     <string value="test4" />
#     <string value="test5" />
#     <string value="test6" />
#   </list>
# </expr>

```

Eğer buradaki modülden daha fazla yerde atama yapmış olsaydık bu durumda mkOrder fonksiyonunu kullanacaktık. Her bir modülde alttaki gibi bir sıra no verecektik. 




```nix
{ lib, config,... }: {
  
  config = { 
    apps.message.iswebsiteBing = lib.mkOverride 50 false; 
    apps.message.list =lib.mkOrder 10 [ "test1" "test2" "test3" ];
    };
  
  }
```


Evet bu yazımızın da sonuna geldik. Bu yazımızda somut olarak modül yazmadık. Amacımız yazarken nelere dikkat etmeliyiz ve nasıl hata çözebiliriz buna odaklanmaktı. Bir sonraki yazımızda artık somut olarak bir önceki yazımızda kurmuş olduğumuz NixOS kurulumundan devam edeceğiz, home-manager'ı inceleyeceğiz.


## Modül ve Option'ları  Daha Detaylı Öğrenmek İçin Kaynaklar
- [NixOs manual](https://nixos.org/manual/nixos/stable/#sec-writing-modules)
- [NixOs Wiki](https://nixos.wiki/wiki/NixOS_modules)
- [Nix Language](https://nix.dev/tutorials/module-system/module-system.html)
- [NixOs Non-Official](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration) 

## Kaynaklar
- https://github.com/Misterio77/nix-starter-configs/tree/main
- https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration
- https://www.tweag.io/blog/2020-07-31-nixos-flakes/
- https://jade.fyi/blog/flakes-arent-real/
- https://github.com/mikeroyal/NixOS-Guide
- https://nixos.wiki/wiki/NixOS_modules
- https://nix.dev/tutorials/module-system/module-system.html
- https://nixos.org/manual/nixos/stable/#sec-writing-modules
- https://dev.to/dooygoy/100-days-of-nixos-346e
- https://github.com/rasendubi/dotfiles
