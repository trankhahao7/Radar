// Sử dụng thư viện Servo
#include <Servo.h>

// Khai báo chân Trig và Echo
const int trigPin = 10;
const int echoPin = 11;

// Khai báo ngưỡng phát hiện vật thể (cm)
const int DETECTION_RANGE = 30; // Thay đổi giá trị này theo nhu cầu

// Khai báo biến thời gian và khoảng cách
long duration;
int distance;

Servo myServo;        // Servo radar - chân 12
Servo alertServo;     // Servo cảnh báo - chân 9

void setup() {
    pinMode(trigPin, OUTPUT); // Set chân trig là chân OUTPUT
    pinMode(echoPin, INPUT);  // Set chân echo INPUT
    Serial.begin(9600);
    myServo.attach(12);   // Chân Servo radar là chân 12
    alertServo.attach(9); // Chân Servo cảnh báo là chân 9
    alertServo.write(0);  // Khởi tạo servo cảnh báo ở góc 0 độ
}

void loop() {
    // Quay Servo từ 15 độ - 165 độ
    for (int i = 15; i <= 165; i++) {
        myServo.write(i);
        delay(30);
        distance = calculateDistance(); // Gọi hàm tính khoảng cách

        // Kiểm tra phát hiện vật thể và điều khiển servo cảnh báo
        if (distance > 0 && distance <= DETECTION_RANGE) {
            alertServo.write(90); // Phát hiện vật thể -> quay 90 độ
        } else {
            alertServo.write(0);  // Không phát hiện -> về 0 độ
        }

        Serial.print(i);         // Gửi giá trị i (góc quay của Servo) đến Serial Port
        Serial.print(",");       // Gửi ","
        Serial.print(distance);  // Tiếp theo gửi các giá trị khoảng cách tới Serial Port
        Serial.print(".");       // Gửi dấu "."
    }

    // Quay ngược lại từ 165 độ về 15 độ
    for (int i = 165; i > 15; i--) {
        myServo.write(i);
        delay(30);
        distance = calculateDistance();

        // Kiểm tra phát hiện vật thể và điều khiển servo cảnh báo
        if (distance > 0 && distance <= DETECTION_RANGE) {
            alertServo.write(90); // Phát hiện vật thể -> quay 90 độ
        } else {
            alertServo.write(0);  // Không phát hiện -> về 0 độ
        }

        Serial.print(i);
        Serial.print(",");
        Serial.print(distance);
        Serial.print(".");
    }
}

// Hàm tính khoảng cách bằng siêu âm
int calculateDistance() {
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    // Phát xung siêu âm với thời gian là 10 Micro giây
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW); // Ngưng phát xung
    duration = pulseIn(echoPin, HIGH); // Tính thời gian xung siêu âm phát ra đập vào vật cản rồi dội lại
    distance = duration * 0.034 / 2;  // Tính khoảng cách (vận tốc âm 344m/s, chia 2 vì đi và về)
    return distance;
}