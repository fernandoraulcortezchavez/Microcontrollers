const int frontSensor = 4;
const int rightSensor = 5;
const int backSensor = 6;
const int leftSensor = 7;
const int ultrasonicTrig = 8;
const int ultrasonicEcho = 9;
const int rightMotor = 11;
const int leftMotor = 12;

boolean frontReading = false;
boolean rightReading = false;
boolean backReading = false;
boolean leftReading = false;

unsigned long currentDistance = 100;

boolean isSensorDetecting(int beaconSensorPin) {
  if (digitalRead(beaconSensorPin) == HIGH)
    return true;
  return false;
}

void readAllBeaconSensors() {
  frontReading = isSensorDetecting(frontSensor);
  rightReading = isSensorDetecting(rightSensor);
  backReading = isSensorDetecting(backSensor);
  leftReading = isSensorDetecting(leftSensor);
}


void turnUntilFacingForward(int rightPWM, int leftPWM) {
  while(!(frontReading and not rightReading and not backReading and not leftReading))
  {
    analogWrite(rightMotor, rightPWM);
    analogWrite(leftMotor, leftPWM);
    delay(50);
    readAllBeaconSensors();
  }  
}

unsigned long distanceToNearestObject(){
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
  // put your main code here, to run repeatedly:
  readAllBeaconSensors();
  if(frontReading){
    digitalWrite(rightMotor, HIGH);
    digitalWrite(leftMotor, HIGH);
  }
  else if (rightReading) {
    turnUntilFacingForward(100, 140);
  }
  else if (backReading) {
    turnUntilFacingForward(0, 200);
  }
  else if (leftReading) {
    turnUntilFacingForward(140, 100);
  }
  currentDistance = distanceToNearestObject();
  Serial.print("Distance: ");
  Serial.println(currentDistance);
  if(distance > 100){
    digitalWrite(rightMotor, LOW);
    digitalWrite(leftMotor, HLOW);
  }
  delay(500);  
}
