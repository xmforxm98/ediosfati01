#!/usr/bin/env python3
"""
Test script to demonstrate the server bug where birth data is ignored.
Run this to see that different birth data produces identical results.
"""

import requests
import json
from datetime import datetime

def test_server_bug():
    url = "https://us-central1-eidosfati.cloudfunctions.net/analyze_all"
    
    # Test cases with different birth data
    test_cases = [
        {
            "name": "Test User 1",
            "birth_year": 1990,
            "birth_month": 1,
            "birth_day": 1,
            "birth_hour": 12,
            "birth_minute": 0,
            "gender": "male"
        },
        {
            "name": "Test User 2", 
            "birth_year": 1975,
            "birth_month": 12,
            "birth_day": 31,
            "birth_hour": 23,
            "birth_minute": 59,
            "gender": "female"
        },
        {
            "name": "Test User 3",
            "birth_year": 2000,
            "birth_month": 6,
            "birth_day": 15,
            "birth_hour": 6,
            "birth_minute": 30,
            "gender": "male"
        }
    ]
    
    print("🧪 Testing server with different birth data...")
    print("Expected: Different eidos types for different birth data")
    print("Current: All return same eidos type\n")
    
    results = []
    
    for i, test_data in enumerate(test_cases, 1):
        # Add current date (this is what server actually uses)
        now = datetime.now()
        request_data = {
            **test_data,
            "year": now.year,
            "month": now.month, 
            "day": now.day
        }
        
        print(f"Test {i}: {test_data['name']}")
        print(f"Birth: {test_data['birth_year']}-{test_data['birth_month']}-{test_data['birth_day']} {test_data['birth_hour']}:{test_data['birth_minute']}")
        
        try:
            response = requests.post(url, json=request_data, headers={'Content-Type': 'application/json'})
            
            if response.status_code == 200:
                data = response.json()
                eidos_type = data.get('eidos_type') or data.get('eidosSummary', {}).get('eidosType', 'Unknown')
                results.append(eidos_type)
                print(f"✅ Result: {eidos_type}")
            else:
                print(f"❌ Error {response.status_code}: {response.text}")
                
        except Exception as e:
            print(f"💥 Exception: {e}")
            
        print()
    
    # Check if all results are identical (this is the bug)
    if len(set(results)) == 1:
        print("🚨 BUG CONFIRMED: All different birth data produced identical results!")
        print(f"All results: {results[0]}")
        print("\n🔧 FIX NEEDED: Server should use birth_year, birth_month, birth_day, birth_hour, birth_minute for calculations")
    else:
        print("✅ Working correctly: Different birth data produced different results")
        for i, result in enumerate(results, 1):
            print(f"User {i}: {result}")

if __name__ == "__main__":
    test_server_bug() 