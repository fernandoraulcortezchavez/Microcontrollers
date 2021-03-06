const int frontSensor = 6;
const int rightSensor = 4;
const int backSensor = 5;
const int leftSensor = 7;
const int ultrasonicTrig = 8;
const int ultrasonicEcho = 9;
const int rightMotor = 11;
const int leftMotor = 12;
const int photoSensor = A0;

boolean frontReading = false;
boolean rightReading = false;
boolean backReading = false;
boolean leftReading = false;
boolean carFound = false;
boolean goalFound = false;

unsigned long currentDistance = 100;

void printReadings() {
  Serial.print("Distance: ");
  Serial.print(currentDistance);
  Serial.print(" Front: ");
  Serial.print(frontReading);
  Serial.print(" Right: ");
  Serial.print(rightReading);
  Serial.print(" Left: ");
  Serial.print(leftReading);
  Serial.print(" Back: ");
  Serial.println(backReading);
}

boolean isSensorDetecting(int beaconSensorPin) {
  if (digitalRead(beaconSensorPin) == HIGH)
    return true;
  return false;
}

void readAllBeaconSensors() {
  frontReading = !isSensorDetecting(frontSensor);
  rightReading = !isSensorDetecting(rightSensor);
  backReading = !isSensorDetecting(backSensor);
  leftReading = !isSensorDetecting(leftSensor);
}


void turnUntilFacingForward(int rightPWM, int leftPWM) {
  while (!(frontReading and not rightReading and not backReading and not leftReading))
  {
    printReadings();
    analogWrite(rightMotor, rightPWM);
    analogWrite(leftMotor, leftPWM);
    delay(50);
    readAllBeaconSensors();
  }
}

void stopMotors() {
  analogWrite(rightMotor, 0);
  analogWrite(leftMotor, 0);
}


unsigned long distanceToNearestObject() {
  digitalWrite(ultrasonicTrig, HIGH);
  delay(10);
  digitalWrite(ultrasonicTrig, LOW);
  return pulseIn(ultrasonicEcho, HIGH) * 0.034 / 2;
}



void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(frontSensor, INPUT);
  pinMode(rightSensor, INPUT);
  pinMode(backSensor, INPUT);
  pinMode(leftSensor, INPUT);
  pinMode(ultrasonicTrig, OUTPUT);
  pinMode(ultrasonicEcho, INPUT);
  pinMode(rightMotor, OUTPUT);
  pinMode(leftMotor, OUTPUT);
}

void loop() {
  /*
     Find the slave car
  */

  if (!carFound) {
    if (currentDistance < 15) {
      carFound = true;
    }
  }
  if (carFound) {
    readAllBeaconSensors();
    printReadings();
    if (frontReading) {
      currentDistance = distanceToNearestObject();
      if (currentDistance > 15) {
        analogWrite(rightMotor, 140);
        analogWrite(leftMotor, 160);
      }
      else {
        analogWrite(rightMotor, 0);
        analogWrite(leftMotor, 0);
      }
    }
    else if (rightReading) {
      turnUntilFacingForward(0, 200);
    }
    else if (backReading) {
      turnUntilFacingForward(0, 250);
    }
    else if (leftReading) {
      turnUntilFacingForward(200, 0);
    }
    else {
      analogWrite(rightMotor, 0);
      analogWrite(leftMotor, 0);
    }
  }
delay(50);
}
