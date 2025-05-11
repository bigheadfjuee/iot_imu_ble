// Tony 更改自 IMU_Capture_BLE_v7
// 加入 BLE 連接時，LED 燈亮
#include <LSM6DS3.h>
#include <Wire.h>
#include <ArduinoBLE.h>

// Create a instance of class LSM6DS3
LSM6DS3 myIMU(I2C_MODE, 0x6A); // I2C device address 0x6A

// BLE Service & Characteristic
BLEService imuService("0769bb8e-b496-4fdd-b53b-87462ff423d0"); // 180C
// 自訂 characteristic UUID  // 固定 32 bytes（timestamp + 6 floats + 1 uint32）
BLECharacteristic imuDataChar("8ee82f5b-76c7-4170-8f49-fff786257090", BLERead | BLENotify, 30); // 2A56

// 電壓快取用的全域變數
unsigned long lastVoltageReadTime = -300000;
int16_t voltageRaw = 0;
const int ledPin = LED_BUILTIN; // pin to use for the LED

void setup()
{
  // put your setup code here, to run once:
  Serial.begin(115200);
  delay(1000); // 加一點緩衝時間
  // while (!Serial); // 沒有接電腦就不會有 Seiral = true

  // set LED pin to output mode
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW); // turn on the LED to indicate the connection:

  // 開啟電壓偵測通道
  pinMode(P0_14, OUTPUT);
  digitalWrite(P0_14, LOW);

  // 設定 D13 為低電流充電
  pinMode(P0_13, OUTPUT);
  digitalWrite(P0_13, HIGH);

  // 設定 I²C 傳輸頻率為 400kHz
  Wire.begin();
  Wire.setClock(400000); // Fast Mode

  // 設定 IMU ODR 參數
  myIMU.settings.accelBandWidth = 50;
  myIMU.settings.gyroBandWidth = 50;

  // Call .begin() to configure the IMUs
  if (myIMU.begin() != 0)
  {
    Serial.println("Device error");
  }
  else
  {
    Serial.println("timestamp,aX,aY,aZ,gX,gY,gZ");
  }

  // 初始化 BLE
  if (!BLE.begin())
  {
    Serial.println("BLE init failed");
    while (1)
      ;
  }

  imuService.addCharacteristic(imuDataChar);
  BLE.addService(imuService);
  imuDataChar.setValue((uint8_t *)"", 0); // 設定一個初始空值，避免 notify 錯誤

  BLE.setLocalName("SmartRacket");
  BLE.setAdvertisedService(imuService);
  BLE.advertise();

  Serial.println("BLE advertising started...");
}

void loop()
{
  BLEDevice central = BLE.central();

  if (central)
  {
    Serial.println("Connected to central");
    Serial.println(central.address());

    // turn off the LED to indicate the connection:
    digitalWrite(ledPin, HIGH);

    // 初始化時間記錄
    unsigned long lastSendTime = 0;
    const unsigned long interval = 20; // 每 20ms 傳一次

    while (central.connected())
    {

      unsigned long now = millis();

      // 每 300,000 ms 讀一次電壓
      if (now - lastVoltageReadTime >= 300000)
      { // 5 分鐘 = 300,000 ms
        voltageRaw = analogRead(A0);
        lastVoltageReadTime = now;
      }

      if (now - lastSendTime >= interval)
      {
        lastSendTime = now;

        uint32_t timestamp = millis(); // 加入時間戳  用 millis() 當 timestamp
        float aX = myIMU.readFloatAccelX();
        float aY = myIMU.readFloatAccelY();
        float aZ = myIMU.readFloatAccelZ();
        float gX = myIMU.readFloatGyroX();
        float gY = myIMU.readFloatGyroY();
        float gZ = myIMU.readFloatGyroZ();

        // 藍牙傳送資料
        // 打包資料
        uint8_t buffer[30];
        memcpy(buffer, &timestamp, 4);
        memcpy(buffer + 4, &aX, 4);
        memcpy(buffer + 8, &aY, 4);
        memcpy(buffer + 12, &aZ, 4);
        memcpy(buffer + 16, &gX, 4);
        memcpy(buffer + 20, &gY, 4);
        memcpy(buffer + 24, &gZ, 4);
        memcpy(buffer + 28, &voltageRaw, 2);

        // 傳送資料 via BLE notify
        if (BLE.connected())
        {
          imuDataChar.writeValue(buffer, 30);
        }
      }
    }
    // when the central disconnects, turn off the LED:
    digitalWrite(ledPin, HIGH);
    Serial.println("Disconnected from central");
    digitalWrite(ledPin, HIGH); // turn off the LED to indicate the connection:
  }
}