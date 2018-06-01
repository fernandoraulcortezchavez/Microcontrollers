#include <Time.h>
#include <TimeLib.h>

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

void printReadings(){
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
  while(!(frontReading and not rightReading and not backReading and not leftReading))
  {
    printReadings();
    analogWrite(rightMotor, rightPWM);
    analogWrite(leftMotor, leftPWM);
    delay(50);
    readAllBeaconSensors();
  }  
}

void stopMotors(){
  analogWrite(rightMotor, 0);
  analogWrite(leftMotor, 0);
}

void turnNinetyDegreesRight(int times){
  for (int i = 0; i < times; i++){
  analogWrite(rightMotor, 0);
  analogWrite(leftMotor, 200);
  delay(550); //Tentative to let run the motors
  stopMotors();
  delay(200);
  Serial.println("Running");
  }
  
}

void seekLight(){
    /*photoValue = analogRead(photoSensor);
    while(photoValue > 500){
      analogWrite(rightMotor, 200);
      analogWrite(leftMotor, 0);
    }
    analogWrite(rightMotor, 200);
    analogWrite(leftMotor, 200);*/
    int bestPhotoReading = 1023;
    int currentPhotoReading = 2000;
    long previousTime;
    long currentTime;
    currentPhotoReading = analogRead(photoSensor);
    
    while(!goalFound) {
      previousTime = millis();
      while(true){
        analogWrite(rightMotor, 200);
        analogWrite(leftMotor, 220);
        currentTime = millis();
        if (currentTime - previousTime >= 1300){
          // Return to previous point to choose another direction.
         turnNinetyDegreesRight(2);
         analogWrite(rightMotor, 200);
         analogWrite(leftMotor, 220);
         delay(1300);
         stopMotors();
         delay(10);
         turnNinetyDegreesRight(1);
         delay(300);
         break;
        }
        else{
         currentPhotoReading = analogRead(photoSensor);
         Serial.print("Current: ");
         Serial.print(currentPhotoReading);
         Serial.print(" Best: ");
         Serial.println(bestPhotoReading);
         if (currentPhotoReading < bestPhotoReading) {
           bestPhotoReading = currentPhotoReading;
           previousTime = currentTime;
           if (currentPhotoReading < 600){
            goalFound = true;
            break;
           }
         }
        }
       }
       
       
      }
      
      //delay(800); // Let the car go forward some time
      /*currentPhotoReading = analogRead(photoSensor);
      Serial.print("Current: ");
      Serial.print(currentPhotoReading);
      Serial.print(" Best: ");
      Serial.println(bestPhotoReading);
      if (currentPhotoReading > bestPhotoReading) {
        // Return to previous point to choose another direction.
        turnNinetyDegreesRight(2);
        analogWrite(rightMotor, 200);
        analogWrite(leftMotor, 230);
        delay(800);
        turnNinetyDegreesRight(1);
      }
      else{
        // A better reading was found, continue that way
        bestPhotoReading = currentPhotoReading;
      }  */    
    
    goalFound = true;
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
  /*
   * Find the slave car
   */
  /*while(true){
    //turnUntilFacingForward(0, 200);
    //turnNinetyDegreesRight(1);     // TESTING
    //delay(1500);
    seekLight();
    if (goalFound){
      stopMotors();
      while(true){
        delay(1000);
      }
    }
  }*/
  if(!carFound){
    readAllBeaconSensors();
    printReadings();
    if(frontReading){
      currentDistance = distanceToNearestObject();
      if (currentDistance > 15){
        analogWrite(rightMotor, 160);
        analogWrite(leftMotor, 180);
      }
      else{
        analogWrite(rightMotor, 0);
        analogWrite(leftMotor, 0);
        /*while(true){
            delay(100);
        }*/
        carFound = true;
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
    else{
      analogWrite(rightMotor, 0);
      analogWrite(leftMotor, 0);
    }
  }
  else if(!goalFound){
    /*
     * Find the goal by reading the fotoresistor and heading to areas with greater light
     */
     seekLight();
  }
  else {
    /*
     * Goal reached. Stop car.
     */
    while(true){
      delay(10000);
    }
  }
  //////////////////////////////////////////////////////////
  
  
  /*if(currentDistance < 15){
    digitalWrite(rightMotor, LOW);
    digitalWrite(leftMotor, LOW);
  }
  else{
    analogWrite(rightMotor, 150);
    analogWrite(leftMotor, 150);
  }*/
  
  delay(50);  
}
