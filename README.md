# 🚀 Bora-SSH

<div align="center">

```
__________                                _________ _________ ___ ___  
\______   \ ________________             /   _____//   _____//   |   \ 
 |    |  _//  _ \_  __ \__  \    ______  \_____  \ \_____  \/    ~    \
 |    |   (  <_> )  | \// __ \_ /_____/  /        \/        \    Y    /
 |______  /\____/|__|  (____  /         /_______  /_______  /\___|_  / 
        \/                  \/                  \/        \/       \/  
```

**OpenSource CLI SSH Client for Macbook** 🍎

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/platform-macOS-blue.svg)](https://www.apple.com/macos/)

*Modern, colorful, and intuitive SSH connection manager for macOS*

</div>

---

## 📸 Ana Menü Görünümü

```
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║  ┌────────────────────────────────────────────────────┐    ║
║  │  BORA-SSH Connection Manager                        │    ║
║  ├────────────────────────────────────────────────────┤    ║
║  │                                                      │    ║
║  │  ▶ SSH Bağlan                                       │    ║
║  │    Sunucu Ekle                                      │    ║
║  │    Sunucu Düzenle                                   │    ║
║  │    Sunucu Sil                                       │    ║
║  │    Sunucu Listesi                                   │    ║
║  │    Çıkış                                            │    ║
║  │                                                      │    ║
║  ├────────────────────────────────────────────────────┤    ║
║  │  Açık Sekmeler:                                     │    ║
║  │    [1] SSH: Production Server                      │    ║
║  │    [2] SSH: Development Server                    │    ║
║  │    [3] SSH: Staging Server                         │    ║
║  └────────────────────────────────────────────────────┘    ║
║                                                              ║
║  [↑↓] Seç | [Enter] Onayla | [1-9] Sekme Öne Getir | [q] Çıkış
╚══════════════════════════════════════════════════════════════╝
```

---

## ✨ Özellikler

### 🎨 **Modern TUI Design**
- Soft turuncu tonlarında renkli ASCII art başlık
- Terminal tabanlı kullanıcı arayüzü (TUI)
- Akıcı menü navigasyonu

### ⌨️ **Kolay Navigasyon**
- **Yön tuşları** (↑↓) ile menü gezintisi
- **Enter** ile seçim onaylama
- **Rakam tuşları** (1-9) ile açık sekmeleri hızlıca öne getirme
- **q** veya **Esc** ile çıkış

### 💾 **Sunucu Yönetimi**
- ✅ Sunucu ekleme, düzenleme ve silme
- ✅ Kayıtlı sunucuları listeleme
- ✅ Hızlı SSH bağlantısı
- ✅ Otomatik sunucu kaydetme

### 🪟 **Terminal Yönetimi**
- ✅ Yeni SSH bağlantıları otomatik olarak yeni Terminal penceresinde açılır
- ✅ Ana script penceresi açık kalır
- ✅ Açık sekmeleri görüntüleme ve hızlı erişim
- ✅ Sekme başlıklarında sunucu bilgileri

### 🔐 **Güvenlik**
- ✅ Standart SSH protokolü
- ✅ Şifre ve SSH anahtarı desteği
- ✅ Güvenli sunucu bilgisi saklama (`~/.bora-ssh/servers.conf`)

---

## 📦 Kurulum

### Hızlı Başlangıç

```bash
# Repository'yi klonlayın
git clone https://github.com/boracomet/Bora-SSH.git
cd Bora-SSH

# Scripti çalıştırılabilir yapın
chmod +x bora-ssh.sh

# Scripti çalıştırın
./bora-ssh.sh
```

---

## 🚀 Kullanım

### Ana Menü

Script çalıştırıldığında renkli ASCII art başlık ve ana menü görüntülenir:

- **SSH Bağlan** - Kayıtlı sunuculara SSH bağlantısı yap
- **Sunucu Ekle** - Yeni bir sunucu ekle ve kaydet
- **Sunucu Düzenle** - Mevcut sunucu bilgilerini düzenle
- **Sunucu Sil** - Kayıtlı sunucuyu sil
- **Sunucu Listesi** - Tüm kayıtlı sunucuları görüntüle
- **Çıkış** - Programdan çık

### Navigasyon Kısayolları

| Tuş | İşlev |
|-----|-------|
| `↑` `↓` | Menü öğeleri arasında gezin |
| `Enter` | Seçili öğeyi onayla |
| `1-9` | Açık sekmeleri öne getir |
| `q` | Çıkış yap |

### Sunucu Ekleme

1. Ana menüden **"Sunucu Ekle"** seçeneğini seçin
2. Sunucu bilgilerini girin:
   ```
   Sunucu Adı: Production Server
   Host/IP: 192.168.1.100
   Kullanıcı: root
   Port: 22
   ```
3. Kaydetmek istiyorsanız **"e"** (evet) yazın

Sunucu bilgileri `~/.bora-ssh/servers.conf` dosyasına kaydedilir.

### SSH Bağlantısı

1. Ana menüden **"SSH Bağlan"** seçeneğini seçin
2. Kayıtlı sunucular listesinden bir sunucu seçin
3. SSH bağlantısı yeni bir Terminal penceresinde açılır
4. Ana script penceresi açık kalır, yeni bağlantılar ekleyebilirsiniz

### Sekme Yönetimi

Ana menüde açık Terminal sekmeleri otomatik olarak listelenir:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Açık Sekmeler:
  [1] SSH: Production Server
  [2] SSH: Development Server
  [3] SSH: Staging Server
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

Rakam tuşlarına (`1-9`) basarak ilgili sekmeyi hızlıca öne getirebilirsiniz.

---

## ⚙️ Konfigürasyon

### Sunucu Dosyası

Sunucu bilgileri şu dosyada saklanır:
```
~/.bora-ssh/servers.conf
```

Her satır şu formatta:
```
SunucuAdı|Host|Kullanıcı|Port
```

**Örnek:**
```
Production|192.168.1.100|root|22
Development|dev.example.com|admin|2222
Staging|staging.example.com|deploy|22
```

**⚠️ Güvenlik Notu:** `servers.conf` dosyası hassas bilgiler içerdiği için `.gitignore` dosyasına eklenmiştir ve Git'e yüklenmez.

---

## 📋 Gereksinimler

- **macOS** (test edilmiş)
- **Bash** 4.0+
- **SSH** komutları (macOS'ta varsayılan olarak mevcuttur)
- **Terminal.app** (macOS varsayılan terminal uygulaması)

---

## 🎯 Örnek Kullanım Senaryoları

### Senaryo 1: İlk Kullanım

```bash
$ ./bora-ssh.sh

# Ana menü görüntülenir
# "Sunucu Ekle" seçilir
# Sunucu bilgileri girilir ve kaydedilir
# "SSH Bağlan" ile bağlantı kurulur
```

### Senaryo 2: Çoklu Sunucu Yönetimi

```bash
# Birden fazla sunucuya bağlanma
$ ./bora-ssh.sh

# 1. Production Server'a bağlan
# 2. Yeni Terminal penceresi açılır
# 3. Ana menüye dön
# 4. Development Server'a bağlan
# 5. Yeni Terminal penceresi açılır
# 6. Ana menüde [1] ve [2] tuşlarıyla sekmeler arasında geçiş yap
```

### Senaryo 3: Hızlı Sekme Geçişi

```bash
# Ana menüdeyken:
# [1] tuşu → İlk sekme öne gelir
# [2] tuşu → İkinci sekme öne gelir
# [3] tuşu → Üçüncü sekme öne gelir
```

---

## 🛠️ Geliştirme

### Proje Yapısı

```
Bora-SSH/
├── bora-ssh.sh          # Ana script
├── README.md            # Bu dosya
├── .gitignore           # Git ignore dosyası
└── LICENSE              # MIT Lisansı
```

### Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Değişikliklerinizi commit edin (`git commit -m 'Add amazing feature'`)
4. Branch'inizi push edin (`git push origin feature/amazing-feature`)
5. Pull Request oluşturun

---

## 📝 Notlar

- Script terminal tabanlı bir TUI (Text User Interface) kullanır
- Renkler terminal desteğine bağlıdır (256 renk önerilir)
- SSH bağlantıları için gerekli SSH anahtarları veya şifreler kullanılır
- Yeni SSH bağlantıları otomatik olarak yeni Terminal penceresinde açılır
- Ana script penceresi açık kalır, birden fazla bağlantı yönetebilirsiniz
- Sunucu bilgileri `~/.bora-ssh/servers.conf` dosyasında saklanır ve Git'e yüklenmez

---

## 🐛 Bilinen Sorunlar

- Terminal penceresi yönetimi macOS Terminal.app'e özeldir
- Çoklu ekran desteği test edilmemiştir

---

## 📄 Lisans

Bu proje [MIT Lisansı](LICENSE) altında lisanslanmıştır.

```
MIT License

Copyright (c) 2026 Bora

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

---

## 👤 Yazar

**Bora**

- GitHub: [@boracomet](https://github.com/boracomet)
- Repository: [Bora-SSH](https://github.com/boracomet/Bora-SSH)

---

## 🙏 Teşekkürler

- Tüm katkıda bulunanlara teşekkürler!
- Open source topluluğuna teşekkürler!

---

<div align="center">

**⭐ Bu projeyi beğendiyseniz yıldız vermeyi unutmayın! ⭐**

Made with ❤️ for macOS users

</div>
