# DESIGN OF AN AUTOMATED VENDING MACHINE (FSM & SYSTEMVERILOG OOP VERIFICATION)

Báo cáo đề tài nghiên cứu và thiết kế cấu trúc phần cứng mạch điều khiển Máy bán nước tự động (Vending Machine) thuộc môn **Kiến trúc Máy tính (Computer Architecture)** tại **Trường Đại học Bách khoa - ĐHQG TP.HCM** (Khoa Điện - Điện tử, Bộ môn Điện tử).

Dự án tập trung vào việc hiện thực hóa bộ điều khiển bằng máy trạng thái hữu hạn Moore (Moore FSM), tối ưu hóa sơ đồ chuyển đổi trạng thái từ 13 trạng thái xuống 9 trạng thái để giảm giá thành tài nguyên phần cứng, đồng thời xây dựng môi trường kiểm thử tự động toàn diện theo kiến trúc hướng đối tượng (OOP) bằng ngôn ngữ **SystemVerilog**.

---

## 👥 Thành viên thực hiện & Giảng viên hướng dẫn
* **Giảng viên hướng dẫn:** PGS. TS. Trần Hoàng Linh
* **Nhóm sinh viên thực hiện:**
  * **Nguyễn Duy Tuyên** – MSSV: 2213821

---

## ⚙️ Đặc tả thiết kế RTL (RTL Design Specification)

### 1. Sơ đồ giao tiếp phần cứng (Interface Signals)
Hệ thống chấp nhận 3 loại tiền xu đầu vào có mệnh giá tương ứng là 5 cents (Nickel), 10 cents (Dime), và 25 cents (Quarter). Ngưỡng kích hoạt xả nước (Soda) là **20 cents**. Khi số tiền tích lũy đạt hoặc vượt ngưỡng, hệ thống sẽ đồng thời kích hoạt tín hiệu xả và tính toán trả lại tiền thừa tương ứng.

| Tên tín hiệu | Loại cổng | Độ rộng (Bits) | Mô tả chức năng |
| :--- | :---: | :---: | :--- |
| `i_clk` | Input | 1 | Xung clock hệ thống kích hoạt các tác vụ đồng bộ. |
| `i_rst_n` | Input | 1 | Tín hiệu reset cứng toàn mạch (Tích cực mức thấp, bất đồng bộ). |
| `i_nickle` | Input | 1 | Tín hiệu tích cực (Mức 1) khi người dùng nạp tiền xu 5¢. |
| `i_dime` | Input | 1 | Tín hiệu tích cực (Mức 1) khi người dùng nạp tiền xu 10¢. |
| `i_quarter` | Input | 1 | Tín hiệu tích cực (Mức 1) khi người dùng nạp tiền xu 25¢. |
| `o_soda` | Output | 1 | Tích cực mức cao (Mức 1) báo hiệu sản phẩm được xả thành công. |
| `o_change [2:0]` | Output | 3 | Bus dữ liệu nhị phân 3-bit hiển thị lượng tiền thừa trả lại cho khách. |

### 2. Kiến trúc Moore FSM & Tối ưu hóa trạng thái
Dự án áp dụng cấu trúc máy trạng thái kiểu **Moore FSM** để đảm bảo tính ổn định của mạch logic, loại bỏ hoàn toàn các hiện tượng xung nhiễu (glitches) ở ngõ ra do ngõ ra chỉ phụ thuộc duy nhất vào trạng thái hiện tại (`Present State`).

Nhóm đã thực hiện kỹ thuật rút gọn trạng thái (State Reduction) để tối ưu hóa thiết kế logic:
* **Mô hình ban đầu (13 Trạng thái):** Bản đồ đầy đủ của tất cả các nhánh tích lũy từ trạng thái rỗi cho đến khi vượt ngưỡng (S5, S10, S15, S20, S25, S30, S35, S40...).
* **Mô hình tối ưu (9 Trạng thái):** Sát nhập các trạng thái tương đương logic, tối ưu hóa không gian thanh ghi và bảng chuyển đổi trạng thái phần cứng nhưng vẫn duy trì tính đúng đắn 100% của hệ thống.

**Bảng chuyển đổi trạng thái sau tối ưu hóa:**

| Trạng thái hiện tại | Tín hiệu vào (N, D, Q) | Ngõ ra (Soda / Change) | Trạng thái kế tiếp |
| :--- | :---: | :---: | :--- |
| **IDLE** (0¢) | 5¢ / 10¢ / 25¢ | 0 / 3'b000 | S5 / S10 / D25 |
| **S5** (5¢) | 5¢ / 10¢ / 25¢ | 0 / 3'b000 | S10 / S15 / D30 |
| **S10** (10¢) | 5¢ / 10¢ / 25¢ | 0 / 3'b000 | S15 / D20 / D35 |
| **S15** (15¢) | 5¢ / 10¢ / 25¢ | 0 / 3'b000 | D20 / D25 / D40 |
| **D20** (Đạt số dư 20¢) | Khóa / Bỏ qua | 1 / 3'b000 | IDLE |
| **D25** (Dư 5¢ tiền thừa) | Khóa / Bỏ qua | 1 / 3'b001 | IDLE |
| **D30** (Dư 10¢ tiền thừa) | Khóa / Bỏ qua | 1 / 3'b010 | IDLE |
| **D35** (Dư 15¢ tiền thừa) | Khóa / Bỏ qua | 1 / 3'b011 | IDLE |
| **D40** (Dư 20¢ tiền thừa) | Khóa / Bỏ qua | 1 / 3'b100 | IDLE |

---

## 🏗️ Kiến trúc môi trường kiểm thử (Verification Architecture)

Để đảm bảo thiết kế RTL hoạt động chuẩn xác, hệ thống được xác thực thông qua một Testbench hướng đối tượng nâng cao viết bằng **SystemVerilog OOP** bao gồm các khối chức năng phân tầng:

* **Transaction:** Lớp dữ liệu (Data class) đóng gói, định nghĩa cấu trúc các tín hiệu kích thích (coin insertions).
* **Generator:** Tạo kịch bản kiểm thử (Stimulus), hỗ trợ cả hai phương pháp: Định hướng chuỗi cố định (Directed) và Tạo chuỗi ngẫu nhiên có ràng buộc (Constrained Random). Sau đó đẩy dữ liệu vào Mailbox.
* **Driver:** Đóng vai trò thực thi vật lý, liên tục lấy dữ liệu từ Mailbox thông qua cơ chế bắt tay (Handshake FIFO), chuyển đổi các transaction thành các mức logic nhị phân và lái trực tiếp vào các chân của DUT thông qua Giao tiếp ảo (`Virtual Interface - VIF`).
* **DUT (Device Under Test):** Khối FSM máy bán nước tự động cần được kiểm tra.

---

## 📈 Kịch bản kiểm thử & Kết quả mô phỏng

### 1. Kiểm thử định hướng (Directed Test)
Tập trung vào việc kiểm tra độ bao phủ biên (Boundary conditions) và đảm bảo tất cả các trạng thái xả nước từ `D20` đến `D40` đều được kích hoạt chính xác.

* **Case 1 (Target 20¢):** Nạp `10¢ + 10¢` $\rightarrow$ Đạt trạng thái `D20` $\rightarrow$ Kết quả: `o_soda = 1`, `o_change = 3'b000` (PASSED)
* **Case 2 (Target 25¢):** Nạp thẳng xu `25¢` $\rightarrow$ Đạt trạng thái `D25` $\rightarrow$ Kết quả: `o_soda = 1`, `o_change = 3'b001` (PASSED)
* **Case 3 (Target 30¢):** Nạp `5¢ + 25¢` $\rightarrow$ Đạt trạng thái `D30` $\rightarrow$ Kết quả: `o_soda = 1`, `o_change = 3'b010` (PASSED)
* **Case 4 (Target 35¢):** Nạp `10¢ + 25¢` $\rightarrow$ Đạt trạng thái `D35` $\rightarrow$ Kết quả: `o_soda = 1`, `o_change = 3'b011` (PASSED)
* **Case 5 (Target 40¢):** Nạp `5¢ + 10¢ + 25¢` $\rightarrow$ Đạt trạng thái `D40` $\rightarrow$ Kết quả: `o_soda = 1`, `o_change = 3'b100` (PASSED)

### 2. Kiểm thử ngẫu nhiên có ràng buộc (Constrained Random Test)
* **Phương pháp:** Sử dụng hàm biến đổi ngẫu nhiên tự động `randomize()` kết hợp ràng buộc `one-hot` (tại một thời điểm chỉ có tối đa một đồng xu được thả vào).
* **Quy mô:** Thực hiện stress-test liên tục với chuỗi 20 giao dịch hoàn toàn ngẫu nhiên bất quy tắc để mô phỏng hành vi thực tế phức tạp của người dùng.
* **Thời gian chạy:** 500ns tổng thời gian mô phỏng.
* **Trạng thái cuối cùng:** Đạt độ chính xác chức năng **100% (PASSED)**, không xảy ra lỗi sụt áp ngõ ra hay mất dữ liệu truyền nhận qua Mailbox.

---

## 📝 Kết luận
Dự án đã thiết kế và triển khai thành công bộ điều khiển Vending Machine tối ưu bằng Moore FSM tiết kiệm tài nguyên. Việc áp dụng thành công mô hình xác thực hướng đối tượng SystemVerilog OOP nâng cao hiệu quả bao phủ lỗi phần cứng tốt hơn rất nhiều so với phương pháp viết Testbench tuyến tính truyền thống, tạo nền tảng vững chắc để phát triển các hệ thống vi mạch (IC Design) có quy mô lớn hơn.
