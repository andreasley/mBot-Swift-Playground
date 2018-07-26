//#-hidden-code
import PlaygroundSupport
import UIKit
//#-end-hidden-code
/*:
 Modify the code below to allow the mBot to travel in a triangle. You should also do a loop.
 */
//#-hidden-code
playgroundPrologue()
detectUltrasonic(port: 3) { value in
    
}
detectLineSenor(port: 2) { value in
    
}
detectLightSensor() { value in
    
}
wait(duration: 1.5)

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(identifier, show, light, line, ultrasonic, stop(), move(leftSpeed:rightSpeed:), wait(duration:), stop(), playSound(tone:meter:), sendInfraredMessage(message:), show(text:), turnLED(item:color:))
//#-code-completion(keyword, show, for, func, if, var, while)
//#-hidden-code
DispatchQueue.global().async {
//#-end-hidden-code
    
//#-editable-code Tap to enter code
    func goForward(){
        
    }
    
    func turnLeft(){
        
    }
    
    func triangle(){
        move(leftSpeed: 100, rightSpeed: -100)
        wait(duration: 2)
    }
    
    triangle()
//#-end-editable-code
    
//#-hidden-code
}
//Loader.sharedTaskMgr.sendTasks()
//#-end-hidden-code
