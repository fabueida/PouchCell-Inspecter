⸻

🔋 Pouch Cell Inspector

The battery pouch cells identifier application  is a cutting edge tool that uses machine-learning–powered computer vision to detect bulging lithium-ion pouch cells using only an iPhone camera.

Built with Swift, SwiftUI, Vision, and CoreML, the app delivers a fast, reliable, and fully on-device battery safety inspection tool designed for:
	•	🔧 Technicians
	•	🧪 Engineers & researchers
	•	🏭 Lab and industrial environments
	•	📱 Field inspections

The system emphasizes accuracy, accessibility, privacy, and real-world usability, enabling safe and consistent inspections without specialized hardware.

⸻

🎯 Project Purpose

Lithium-ion pouch cells may bulge due to gas buildup, aging, overcharging, or internal failure. Swelling is an early warning sign of potential battery hazards.

Pouch Cell Inspector was developed to:
	•	Provide rapid visual safety checks
	•	Reduce reliance on subjective manual inspection
	•	Deliver consistent ML-based classification
	•	Support documentation and traceability
	•	Enable accessible inspection workflows
	•	Operate fully offline for data privacy

This project is grounded in research on mobile computer vision for battery safety and aims to support real-world industrial and laboratory applications.

⸻

✨ Features

🔍 Real-Time Bulging Detection

A trained CoreML model classifies pouch cells as:
	•	Normal
	•	Bulging

Results are returned in seconds with confidence scores.

⸻

📷 Flexible Image Sources

Users can inspect cells using:
	•	Live camera capture
	•	Photo Library import

This allows:
	•	Field use in varied environments
	•	Reviewing previously captured images
	•	Safer analysis when live alignment is difficult

⸻

🧠 Intelligent Image Preprocessing

The app automatically:
	•	Normalizes lighting
	•	Resizes inputs to match model expectations
	•	Adjusts exposure
	•	Improves consistency across environments

⸻

📊 Results & Confidence Metrics

Each inspection includes:
	•	Classification result
	•	Confidence percentage
	•	Timestamp
	•	Optional notes

⸻

🗂 Local Inspection History
	•	Past inspections are saved automatically
	•	Includes thumbnails and metadata
	•	Enables traceability and later review

⸻

📄 Report Generation

Export structured reports (PDF/JSON) for:
	•	Lab documentation
	•	Safety audits
	•	Research records

⸻

🔒 Fully Offline Processing

All ML inference happens on-device:
	•	No internet required
	•	No images uploaded
	•	Preserves privacy and industrial data security

⸻

♿ Accessibility & Speech Support

Pouch Cell Inspector is designed for visually impaired, low-vision, and motor-impaired users.

Accessibility features include:
	•	VoiceOver-friendly interface
	•	Large, scalable text
	•	High-contrast UI
	•	Speech feedback for classification results
	•	Audio + haptic confirmation cues
	•	Guided capture instructions
	•	Screen-reader-friendly error messages

These features ensure the inspection workflow remains usable in industrial, lab, and consumer environments, regardless of visual ability.

⸻

🛠 Built With
	•	Swift
	•	SwiftUI
	•	CoreML
	•	Vision Framework
	•	AVFoundation
	•	Apple Human Interface Guidelines (HIG)

⸻

🚀 Getting Started

1️⃣ Clone the Repository

git clone https://github.com/<your-org>/Pouch-Cell-Inspector.git
cd Pouch-Cell-Inspector


⸻

2️⃣ Requirements
	•	macOS
	•	Xcode 15+
	•	iOS 14+ device or simulator
	•	Apple Developer account (for physical device testing)

⸻

3️⃣ Open in Xcode

open PouchCellInspector.xcodeproj

All dependencies are native to iOS — no external packages required.

⸻

4️⃣ Run the App
	1.	Select a simulator or physical device
	2.	Press Run (⌘R)

For physical devices:
	•	Enable Developer Mode
	•	Trust the developer certificate

⸻

🤖 Machine Learning Model

The project includes:
	•	A trained CoreML classification model
	•	Image preprocessing pipeline
	•	Evaluation metrics (accuracy, precision, recall)

To replace the model:
	1.	Export a new .mlmodel file
	2.	Place it in:

PouchCellInspector/Model/

	3.	Rebuild the project

⸻

📚 Engineering & Research Documentation

This project follows structured software engineering and research practices, including:
	•	Software Quality Assurance planning (testing strategy, reviews, defect tracking)
	•	Software Project Planning (resources, risks, workflow)
	•	Research-driven ML methodology for battery safety detection

These practices ensure the system is built with a focus on reliability, safety, and real-world deployment readiness.

⸻

🧪 Testing
	•	Unit tests
	•	Integration tests
	•	System tests
	•	ML evaluation tests
	•	Accessibility validation

⸻

🔮 Future Enhancements
	•	Cloud syncing for lab environments
	•	Multi-cell batch scanning
	•	Severity grading (beyond binary classification)
	•	Thermal + vision sensor fusion

⸻

🚧 Project Status

Active development — features, UI, and model performance continue to improve.

⸻

💡 Impact

Pouch Cell Inspector supports early detection of battery deformation, helping:
	•	Improve operational safety
	•	Reduce inspection subjectivity
	•	Support research and diagnostics
	•	Enable accessible industrial software

⸻

Built for safety, accessibility, and real-world performance.