#!/usr/bin/env python3
"""
Firestore에 업로드된 법적 문서들을 확인하는 스크립트
"""

import firebase_admin
from firebase_admin import credentials, firestore
from datetime import datetime

def initialize_firebase():
    """Firebase 초기화"""
    if not firebase_admin._apps:
        cred = credentials.Certificate('service-account-key.json')
        firebase_admin.initialize_app(cred)
    
    return firestore.client()

def check_legal_documents():
    """업로드된 법적 문서들 확인"""
    
    db = initialize_firebase()
    
    try:
        # 법적 문서 컬렉션의 모든 문서 가져오기
        docs = db.collection('legal_documents').get()
        
        print("📋 업로드된 법적 문서 목록:")
        print("=" * 50)
        
        for doc in docs:
            if doc.exists:
                doc_data = doc.to_dict()
                print(f"\n📄 문서 ID: {doc.id}")
                print(f"   제목: {doc_data.get('title', 'N/A')}")
                print(f"   버전: {doc_data.get('version', 'N/A')}")
                print(f"   언어: {doc_data.get('language', 'N/A')}")
                print(f"   활성화: {doc_data.get('active', 'N/A')}")
                
                # 업데이트 시간 포맷팅
                updated_at = doc_data.get('updated_at')
                if updated_at:
                    formatted_date = updated_at.strftime('%Y-%m-%d %H:%M:%S')
                    print(f"   업데이트: {formatted_date}")
                
                # 내용 미리보기 (처음 100자)
                content = doc_data.get('content', '')
                preview = content[:100] + '...' if len(content) > 100 else content
                print(f"   내용 미리보기: {preview}")
            else:
                print(f"\n📄 문서 ID: {doc.id} (존재하지 않음)")
            
        print("\n" + "=" * 50)
        print(f"💾 총 {len(docs)}개의 문서가 발견되었습니다.")
        
    except Exception as e:
        print(f"❌ 문서 확인 중 오류 발생: {e}")

if __name__ == "__main__":
    check_legal_documents() 