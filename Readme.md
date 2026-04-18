Pouch Cell Inspector

The Battery Pouch Cells identifier application is a cutting edge tool that uses machine-learning–powered computer vision to detect bulging lithium-ion pouch cells using only an iPhone camera.
 This application delivers a fast, reliable, and fully on-device battery safety inspection tool designed for:
- Technicians  
- Engineers and researchers  
- Lab and industrial environments  
- Field inspections  

The system emphasizes accuracy, accessibility, privacy, and real-world usability, enabling safe and consistent inspections without specialized hardware.

A key design goal is inclusive use: the app is built with visually impaired  users in mind and supports a fully accessible workflow using VoiceOver, spoken feedback, and haptics.

---

## Project Purpose

Lithium-ion pouch cells may bulge due to gas buildup, aging, overcharging, or internal failure. Swelling is an early warning sign of potential battery hazards.

Pouch Cell Inspector was developed to:
- Provide rapid visual safety checks  
- Reduce reliance on subjective manual inspection  
- Deliver consistent machine learning-based classification  
- Support documentation and traceability  
- Enable accessible inspection workflows  
- Operate fully offline for data privacy  

This project is grounded in research on mobile computer vision for battery safety and aims to support real-world industrial and laboratory applications.

---

## Features

## Real-Time classification Detection

A trained CoreML model classifies pouch cells as:
- Normal  
- Bulging  

Results are returned in seconds with confidence scores.

---

## Flexible Image Sources

Users can inspect cells using:
- Live camera capture  
- Photo Library import  

This allows:
- Field use in varied environments  
- Reviewing previously captured images  
- Safer analysis when live alignment is difficult  

Even if you do not have a pouch cell in front of you, live camera capture can still be used by scanning another device with an online image of the given pouch cell, while still delivering real time classification results.  

---

## Intelligent Image Preprocessing

The app automatically:
- Normalizes lighting  
- Resizes inputs to match model expectations  
- Adjusts exposure  
- Improves consistency across environments  

---

## Results and Confidence Metrics

Each inspection includes:
- Classification result  
- Confidence percentage  
- Timestamp  
- Optional notes  

In addition, the app can speak the result immediately after a scan, announcing the classification and confidence to support users with visual impairments. 

---

## Local Inspection History

- Past inspections are saved automatically  
- Includes thumbnails and metadata  
- Enables traceability and later review  

---


- Safety audits  
- Research records  

---

## Fully Offline Processing

All ML inference happens on-device:
- No internet required  
- No images uploaded  
- Preserves privacy and industrial data security  

---

## Accessibility and Multisensory Feedback

Pouch Cell Inspector is designed to be usable in industrial, lab, and field environments by users with a wide range of abilities, including visually impaired and low-vision users.

Accessibility features include:
- Fully VoiceOver-accessible interface across the inspection workflow  
- Large, scalable text and high-contrast UI support  
- Spoken feedback after scanning that announces the classification result (and confidence), enabling eyes-free operation  
- Guided capture instructions and screen-reader-friendly error messages  
- Haptic feedback confirmation cues, including distinct haptic patterns by condition (for example, different haptic “feels” for Normal vs. Bulging), supporting users who may not be able to rely on sound or vision, including deaf-blind users  

These features help ensure inspections remain consistent, accessible, and safe without requiring specialized hardware.

---

## Built With

- Swift  
- SwiftUI  
- CoreML  
- Vision Framework  
- AVFoundation  
- Apple Human Interface Guidelines (HIG)  

---

## Getting Started for Users

1. Download from the iOS App Store:
https://apps.apple.com/us/app/pouch-cell-inspector/id6757132440

---

2. Grant Permissions if Needed

After installing the application, open it and follow any permission prompts if they appear.

The app may request:
- Camera access for live pouch cell scanning
- Photo Library access for importing existing images

Permissions can be changed later in the iPhone Settings app.

---

3. Capture a Pouch Cell Image

To inspect a pouch cell using the camera:

1. Open Pouch Cell Inspector
2. Point the camera at the pouch cell, or any online image
3. Tap the **Take Picture** button or camera capture icon
4. Wait for the app to process the image
5. Review the classification result and confidence score

The app will classify the pouch cell as **Normal** **Bulging** or ** unknown if No pouch cell is detected**.

---

4. Import a Photo

Users can also inspect an existing image from their Photo Library.

To import a photo:

1. Tap the **Import from Library** button or photo icon
2. Choose a pouch cell image from your Photo Library
3. Wait for the app to classify the image
4. Review the result and confidence score

This is useful for reviewing previously captured images or inspecting a pouch cell image when live camera scanning is not available.

---

5. View Inspection History

The app includes a history feature for reviewing previous inspection results.

To view past inspections:

1. Tap **View Classification History**
2. Browse previous scan results
3. Select a saved result to review its classification details

Inspection history can help users keep track of past results, timestamps, and scan records.

---

6. View Safety Info

The **Safety Info** section teaches important information about lithium-ion pouch batteries.

This section explains:
- What pouch cell swelling may indicate
- Why bulging lithium-ion batteries can be dangerous
- General safety precautions
- When users should stop using or handling a damaged cell

Safety information is provided for awareness and should not replace professional battery safety procedures when required.

---

7. Change Settings

Users can tap the **Settings** icon in the top-left corner of the app to change preferences at any time.

Settings may include:
- Spoken feedback
- Haptic feedback
- Display or appearance options
- Privacy information

---

8. View Privacy Policy

Pouch Cell Inspector is designed with privacy in mind. Machine learning classification runs on-device, and images are not uploaded to a cloud server for inspection.

View our privacy policy here:
https://github.com/fabueida/PouchCellInspector-PrivacyPolicy

## getting started for developers 

1. Clone the Repository

```bash
git clone https://github.com/<your-org>/Pouch-Cell-Inspector.git
cd Pouch-Cell-Inspector
```

---

2. Requirements

- macOS  
- Xcode 15+  
- iOS 14+ device or simulator  
- Apple Developer account (for physical device testing)  

---

3. Open in Xcode

```bash
open PouchCellInspector.xcodeproj
```

All dependencies are native to iOS — no external packages required.

---

4. Run the App

1. Select a simulator or physical device  
2. Press Run (Command + R)

For physical devices:
- Enable Developer Mode  
- Trust the developer certificate  

---

## Machine Learning Model

The project includes:
- A trained CoreML classification model  
- Image preprocessing pipeline  
- Evaluation metrics (accuracy, precision, recall)  

To replace the model:
1. Export a new .mlmodel file  
2. Place it in:

PouchCellInspector/Model/

3. Rebuild the project  

---

## Engineering and Research Documentation

This project follows structured software engineering and research practices, including:
- Software Quality Assurance planning (testing strategy, reviews, defect tracking)  
- Software Project Planning (resources, risks, workflow)  
- Research-driven ML methodology for battery safety detection  

These practices ensure the system is built with a focus on reliability, safety, accessibility, and real-world deployment readiness.

---

## Testing

- Unit tests  
- Integration tests  
- System tests  
- ML evaluation tests  
- Accessibility validation  

---

## Future Enhancements

- Cloud syncing for lab environments  
- Multi-cell batch scanning  
- Severity grading (beyond binary classification)  
- Thermal + vision sensor fusion  

---

## Project Status

Active development — features, UI, and model performance continue to improve.

---

## Impact

Pouch Cell Inspector supports early detection of battery deformation, helping:
- Improve operational safety  
- Reduce inspection subjectivity  
- Support research and diagnostics  
- Enable accessible industrial software  

---

Built for safety, accessibility, and real-world performance.