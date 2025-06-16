# Process Collector

Bu servis, sistem proceslerini izleyerek güvenlik analizi için veri toplar.

## Derleme

```bash
# Ana dizinden:
mkdir build && cd build
cmake ..
make process-collector

# Veya sadece bu servisi derlemek için:
cd services/collectors/process-collector
mkdir build && cd build
cmake ..
make
```

## Çalıştırma

```bash
./process-collector
```

## Geliştirme

- **Header dosyaları**: `include/` klasöründe
- **Kaynak kodlar**: `src/` klasöründe  
- **Testler**: `tests/` klasöründe (GTest kullanılacak)

## TODO

- [ ] Sistem process listesi okuma
- [ ] Memory usage monitoring
- [ ] Network connections tracking
- [ ] GTest ile unit test yazma
