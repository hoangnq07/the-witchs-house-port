# The Witch's House (Ngôi Nhà Phù Thủy) - Port ArkOS & Việt Hóa

Bản port hoàn chỉnh tựa game kinh dị giải đố kinh điển **The Witch's House (Majo no Ie)** dành cho hệ máy cầm tay chạy **ArkOS** (R36S, Anbernic RG351/RG353, Powkiddy v.v.) thông qua PortMaster / mkxp-z, đi kèm bản dịch **Việt Hóa toàn diện 100%** (chuyển thể từ bản dịch chuẩn của 37TEAM & AowVN).

---

## 🎮 Tính năng nổi bật của bản Port

- **Tương thích hoàn hảo với ArkOS & R36S**: Tích hợp binary ARM64 `falcon_mkxp`, các thư viện phụ thuộc (`libs/`), cùng script khởi chạy tự động tối ưu xung nhịp CPU/GPU governor sang chế độ `performance`.
- **Việt Hóa 100%**:
  - Dịch toàn bộ cốt truyện, lời thoại và toàn bộ 113 khu vực bản đồ.
  - Dịch 100% tên vật phẩm, mô tả vật phẩm trong túi đồ.
  - Dịch toàn bộ hệ thống giao diện: Menu chính, Pause menu, Màn hình Lưu/Tải game, Hộp thoại lựa chọn.
- **Xử lý triệt để hệ thống lựa chọn nâng cao (Script 104 - ●選択肢拡張)**:
  - Tự động hook class `Game_Choices` và `Window_Choice` tại runtime để dịch toàn bộ 129 lựa chọn tương tác ("Lấy nó", "Không lấy nó", "Đọc", "Không đọc", "Nựng con ếch", "Cắt bỏ tay chân gấu bông", "Mở cửa", v.v.).
  - Tự động tính toán lại kích thước khung lựa chọn (`choise_width`) vừa vặn hoàn hảo với độ dài chữ tiếng Việt.
- **Sửa lỗi hiển thị Font chữ tiếng Việt**:
  - Tích hợp bộ font `VL PGothic` và `OpenSans` hỗ trợ đầy đủ ký tự Unicode tiếng Việt có dấu.
  - Hook cơ chế ngắt ký tự UTF-8 nhiều byte (`/./um`) trong `Window_Message`, loại bỏ hoàn toàn hiện tượng chữ có dấu bị lỗi hoặc biến thành dấu chấm (`.`).
- **Khắc phục lỗi Crash khi lưu game**:
  - Vô hiệu hóa `save_png` (gốc dùng Zlib C++ không tương thích trên mkxp Linux) để game lưu và tải màn chơi mượt mà không bị văng.
- **Điều khiển tay cầm tối ưu hóa (GPTK)**:
  - Cấu hình sẵn phím bấm trực quan cho D-Pad, cần Analog và các nút A/B/X/Y.

---

## 🕹️ Điều khiển (Controls)

Cấu hình sẵn qua `the_witchs_house.gptk`:

| Nút trên Handheld | Chức năng trong Game |
| :--- | :--- |
| **D-Pad / Analog Trái** | Di chuyển nhân vật (Lên / Xuống / Trái / Phải) |
| **Nút A / R1** | Tương tác / Kiểm tra / Xác nhận (Enter) |
| **Nút B / Back** | Hủy / Thoát / Mở Menu túi đồ (Esc) |
| **Nút X / L1** | Giữ để Chạy nhanh (Dash / Shift) |
| **Nút Y** | Phím cách (Space) |
| **Start** | Xác nhận / Bắt đầu (Enter) |

---

## 📂 Hướng dẫn cài đặt vào thẻ nhớ ArkOS

1. Kết nối thẻ nhớ của máy (thường là thẻ chứa thư mục ROM) vào máy tính.
2. Sao chép file **`The Witch's House.sh`** vào thư mục:
   ```
   roms/ports/
   ```
   *(hoặc `roms2/ports/` nếu bạn dùng máy 2 thẻ nhớ)*
3. Sao chép toàn bộ thư mục **`the_witchs_house/`** vào:
   ```
   roms/ports/the_witchs_house/
   ```
4. Cắm thẻ nhớ lại vào máy cầm tay (R36S / Anbernic), vào mục **Ports**, chọn **The Witch's House** để thưởng thức!

---

## 📁 Cấu trúc thư mục

```
the_witchs_house_port/
├── The Witch's House.sh           # Script khởi chạy cho ArkOS / PortMaster
├── the_witchs_house/
│   ├── cover.png                  # Ảnh bìa hiển thị trong EmulationStation
│   ├── gameinfo.xml               # Thông tin siêu dữ liệu hiển thị (Metadata)
│   ├── falcon_mkxp.bin            # Engine RPG Maker VX cho ARM64
│   ├── mkxp.conf                  # Cấu hình đồ họa, âm thanh và font mapping
│   ├── the_witchs_house.gptk      # Cấu hình nút bấm tay cầm
│   ├── Fonts/                     # Font chữ hỗ trợ tiếng Việt (VL-PGothic, OpenSans)
│   ├── libs/                      # Các thư viện liên kết động ARM64
│   └── gamedata/                  # Dữ liệu game gốc & bản mod
│       ├── Audio/                 # BGM, BGS, ME, SE
│       ├── Data/                  # Map*.rvdata, CommonEvents, System, Scripts
│       ├── Graphics/              # Characters, Pictures, Titles, System v.v.
│       └── preload/               # Bộ mã nguồn mod Việt Hóa runtime
│           ├── ruby18_comp.rb     # Shim tương thích cú pháp Ruby 1.8
│           ├── win32_wrap.rb      # Giả lập Win32API trên Linux
│           ├── translation.rb     # Engine dịch thuật, hook thoại & choices
│           ├── twh_dict.rb        # Từ điển tiếng Việt dạng thuần Ruby
│           └── twh_dict.json      # Từ điển nguồn dạng JSON
├── .gitignore
└── README.md
```

---

## 💖 Lời cảm ơn & Nguồn gốc (Credits)

- **Tác giả gốc**: [Fummy](http://majonoie.karou.jp/) (Tác giả của kiệt tác *The Witch's House*).
- **Đội ngũ dịch thuật Việt Hóa**: [37TEAM](https://www.facebook.com/37TeamVH/) & [AowVN.org](https://aowvn.org/) (Bản dịch tiếng Việt chất lượng cao).
- **Engine mkxp-z**: Dự án mã nguồn mở tái hiện engine RPG Maker cho Linux/ARM.
- **PortMaster**: Dự án cổng game cho thiết bị cầm tay retro Linux.
