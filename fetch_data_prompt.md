# Test Data Generation Prompt

You are setting up a "Golden Set" of test data for an Appraisal App. You need to gather images and create a JSON file for a specific list of firearms.

## Instructions

1.  **Create Directory Structure**:
    Create a folder named `golden_set`. Inside it, create subfolders for each of the following items (matching the IDs in the JSON section below).

2.  **Download Images**:
    Search for and download at least **2 high-quality images** for each of the following firearms. Save them into their respective folders.
    - **Winchester Model 70 (Pre-64)**:
      - Search: "Winchester Model 70 Pre-64 for sale"
      - Save as: `winchester_model_70/receiver.jpg`, `winchester_model_70/barrel.jpg`
    - **Glock 19 Gen 5**:
      - Search: "Glock 19 Gen 5 for sale"
      - Save as: `glock_19/slide_left.jpg`, `glock_19/slide_right.jpg`
    - **Colt Python (6-inch Blued)**:
      - Search: "Colt Python 6 inch blued for sale"
      - Save as: `colt_python/left_side.jpg`, `colt_python/crane.jpg`
    - **Custom Remington 700**:
      - Search: "Custom Remington 700 precision rifle chassis"
      - Save as: `remington_700_custom/overall.jpg`, `remington_700_custom/action.jpg`
    - **Remington 700 Sendero**:
      - Search: "Remington 700 Sendero SF II"
      - Save as: `remington_700_sendero/overall.jpg`, `remington_700_sendero/barrel_fluting.jpg`
    - **Ruger 77**:
      - Search: "Ruger M77 Hawkeye" or "Ruger 77 Mark II"
      - Save as: `ruger_77/overall.jpg`, `ruger_77/action.jpg`
    - **Desert Eagle**:
      - Search: "Magnum Research Desert Eagle .50 AE"
      - Save as: `desert_eagle/side.jpg`, `desert_eagle/muzzle.jpg`
    - **S&W M&P Competition**:
      - Search: "Smith & Wesson M&P9 M2.0 Performance Center C.O.R.E."
      - Save as: `sw_mp_competition/side.jpg`, `sw_mp_competition/top.jpg`
    - **Sig P226**:
      - Search: "Sig Sauer P226 Legion" or "P226 MK25"
      - Save as: `sig_p226/side.jpg`, `sig_p226/grip.jpg`
    - **Chinese SKS**:
      - Search: "Norinco SKS Type 56"
      - Save as: `chinese_sks/overall.jpg`, `chinese_sks/receiver_markings.jpg`
    - **WASR-10**:
      - Search: "Century Arms WASR-10 AK-47"
      - Save as: `wasr_10/overall.jpg`, `wasr_10/receiver.jpg`
    - **Bulgarian AK**:
      - Search: "Arsenal SAM7" or "Bulgarian Circle 10 AK"
      - Save as: `bulgarian_ak/overall.jpg`, `bulgarian_ak/trunnion_markings.jpg`
    - **Zenith MP5**:
      - Search: "Zenith ZF-5" or "Zenith Z-5RS"
      - Save as: `zenith_mp5/overall.jpg`, `zenith_mp5/magwell.jpg`
    - **AR15 Low End**:
      - Search: "Palmetto State Armory PA-15" or "Anderson AM-15"
      - Save as: `ar15_low/overall.jpg`, `ar15_low/receiver_rollmark.jpg`
    - **AR15 High End**:
      - Search: "Daniel Defense DDM4 V7" or "Geissele Super Duty"
      - Save as: `ar15_high/overall.jpg`, `ar15_high/rail_markings.jpg`
    - **AR15 Custom**:
      - Search: "Custom AR15 build BCM Aero"
      - Save as: `ar15_custom/overall.jpg`, `ar15_custom/receivers.jpg`
    - **Remington 1100 12ga**:
      - Search: "Remington 1100 12 gauge shotgun"
      - Save as: `remington_1100/overall.jpg`, `remington_1100/receiver_scroll.jpg`
    - **Browning Citori**:
      - Search: "Browning Citori 725" or "Citori Lightning"
      - Save as: `browning_citori/overall.jpg`, `browning_citori/receiver_engraving.jpg`

3.  **Create ground_truth.json**:
    In the `golden_set` folder, create a file named `ground_truth.json` with the following content. **IMPORTANT**: Update the `image_filenames` array to match the rigorous filenames you actually saved.

```json
[
  {
    "id": "winchester_model_70",
    "image_filenames": [
      "winchester_model_70/receiver.jpg",
      "winchester_model_70/barrel.jpg"
    ],
    "ocr_text": "Model 70 S/N 12345",
    "expected_analysis": {
      "make": "Winchester",
      "model": "Model 70",
      "variant": "Pre-64",
      "condition_grade": "Very Good",
      "is_current_production": false
    },
    "expected_valuation": { "value": 1200.0, "currency": "USD" }
  },
  {
    "id": "glock_19_gen5",
    "image_filenames": ["glock_19/slide_left.jpg", "glock_19/slide_right.jpg"],
    "ocr_text": "Glock 19 Gen 5",
    "expected_analysis": {
      "make": "Glock",
      "model": "19",
      "variant": "Gen 5",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 450.0, "currency": "USD" }
  },
  {
    "id": "colt_python",
    "image_filenames": ["colt_python/left_side.jpg", "colt_python/crane.jpg"],
    "ocr_text": "Colt Python .357 Magnum",
    "expected_analysis": {
      "make": "Colt",
      "model": "Python",
      "variant": "6-inch Barrel",
      "condition_grade": "Good",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1500.0, "currency": "USD" }
  },
  {
    "id": "remington_700_custom",
    "image_filenames": [
      "remington_700_custom/overall.jpg",
      "remington_700_custom/action.jpg"
    ],
    "ocr_text": "Remington 700",
    "expected_analysis": {
      "make": "Remington",
      "model": "700",
      "variant": "Custom Chassis",
      "condition_grade": "Excellent",
      "is_current_production": false
    },
    "expected_valuation": { "value": 1500.0, "currency": "USD" }
  },
  {
    "id": "remington_700_sendero",
    "image_filenames": [
      "remington_700_sendero/overall.jpg",
      "remington_700_sendero/barrel_fluting.jpg"
    ],
    "ocr_text": "Remington 700 Sendero",
    "expected_analysis": {
      "make": "Remington",
      "model": "700",
      "variant": "Sendero SF II",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1100.0, "currency": "USD" }
  },
  {
    "id": "ruger_77",
    "image_filenames": ["ruger_77/overall.jpg", "ruger_77/action.jpg"],
    "ocr_text": "Ruger M77",
    "expected_analysis": {
      "make": "Ruger",
      "model": "M77",
      "variant": "Hawkeye",
      "condition_grade": "Very Good",
      "is_current_production": true
    },
    "expected_valuation": { "value": 850.0, "currency": "USD" }
  },
  {
    "id": "desert_eagle",
    "image_filenames": ["desert_eagle/side.jpg", "desert_eagle/muzzle.jpg"],
    "ocr_text": "Desert Eagle .50AE",
    "expected_analysis": {
      "make": "Magnum Research",
      "model": "Desert Eagle",
      "variant": "Mark XIX",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1600.0, "currency": "USD" }
  },
  {
    "id": "sw_mp_competition",
    "image_filenames": [
      "sw_mp_competition/side.jpg",
      "sw_mp_competition/top.jpg"
    ],
    "ocr_text": "M&P 2.0 Performance Center",
    "expected_analysis": {
      "make": "Smith & Wesson",
      "model": "M&P9",
      "variant": "Performance Center C.O.R.E.",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 650.0, "currency": "USD" }
  },
  {
    "id": "sig_p226",
    "image_filenames": ["sig_p226/side.jpg", "sig_p226/grip.jpg"],
    "ocr_text": "Sig Sauer P226",
    "expected_analysis": {
      "make": "Sig Sauer",
      "model": "P226",
      "variant": "Legion",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1100.0, "currency": "USD" }
  },
  {
    "id": "chinese_sks",
    "image_filenames": [
      "chinese_sks/overall.jpg",
      "chinese_sks/receiver_markings.jpg"
    ],
    "ocr_text": "Factory 26 symbols",
    "expected_analysis": {
      "make": "Norinco",
      "model": "SKS",
      "variant": "Type 56",
      "condition_grade": "Good",
      "is_current_production": false
    },
    "expected_valuation": { "value": 550.0, "currency": "USD" }
  },
  {
    "id": "wasr_10",
    "image_filenames": ["wasr_10/overall.jpg", "wasr_10/receiver.jpg"],
    "ocr_text": "WASR-10",
    "expected_analysis": {
      "make": "Century Arms",
      "model": "WASR-10",
      "variant": "Romanian AKM",
      "condition_grade": "Good",
      "is_current_production": true
    },
    "expected_valuation": { "value": 750.0, "currency": "USD" }
  },
  {
    "id": "bulgarian_ak",
    "image_filenames": [
      "bulgarian_ak/overall.jpg",
      "bulgarian_ak/trunnion_markings.jpg"
    ],
    "ocr_text": "Circle 10",
    "expected_analysis": {
      "make": "Arsenal",
      "model": "SAM7",
      "variant": "Bulgarian Milled",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1700.0, "currency": "USD" }
  },
  {
    "id": "zenith_mp5",
    "image_filenames": ["zenith_mp5/overall.jpg", "zenith_mp5/magwell.jpg"],
    "ocr_text": "Zenith ZF-5",
    "expected_analysis": {
      "make": "Zenith",
      "model": "ZF-5",
      "variant": "MP5 Clone",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1300.0, "currency": "USD" }
  },
  {
    "id": "ar15_low",
    "image_filenames": [
      "ar15_low/overall.jpg",
      "ar15_low/receiver_rollmark.jpg"
    ],
    "ocr_text": "PA-15 Multi",
    "expected_analysis": {
      "make": "Palmetto State Armory",
      "model": "PA-15",
      "variant": "Standard M4",
      "condition_grade": "Good",
      "is_current_production": true
    },
    "expected_valuation": { "value": 450.0, "currency": "USD" }
  },
  {
    "id": "ar15_high",
    "image_filenames": ["ar15_high/overall.jpg", "ar15_high/rail_markings.jpg"],
    "ocr_text": "Daniel Defense",
    "expected_analysis": {
      "make": "Daniel Defense",
      "model": "DDM4",
      "variant": "V7",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 1800.0, "currency": "USD" }
  },
  {
    "id": "ar15_custom",
    "image_filenames": ["ar15_custom/overall.jpg", "ar15_custom/receivers.jpg"],
    "ocr_text": "Aero Precision X15",
    "expected_analysis": {
      "make": "Aero Precision",
      "model": "M4E1",
      "variant": "Custom Build",
      "condition_grade": "Very Good",
      "is_current_production": true
    },
    "expected_valuation": { "value": 900.0, "currency": "USD" }
  },
  {
    "id": "remington_1100",
    "image_filenames": [
      "remington_1100/overall.jpg",
      "remington_1100/receiver_scroll.jpg"
    ],
    "ocr_text": "Remington 1100",
    "expected_analysis": {
      "make": "Remington",
      "model": "1100",
      "variant": "Standard Field",
      "condition_grade": "Good",
      "is_current_production": false
    },
    "expected_valuation": { "value": 600.0, "currency": "USD" }
  },
  {
    "id": "browning_citori",
    "image_filenames": [
      "browning_citori/overall.jpg",
      "browning_citori/receiver_engraving.jpg"
    ],
    "ocr_text": "Browning Citori",
    "expected_analysis": {
      "make": "Browning",
      "model": "Citori",
      "variant": "725 Field",
      "condition_grade": "Excellent",
      "is_current_production": true
    },
    "expected_valuation": { "value": 2200.0, "currency": "USD" }
  }
]
```

4.  **Zip It Up**:
    Compress the `golden_set` folder into `golden_set.zip` so I can transfer it easily.
