#!/usr/bin/env python3
"""
단일 이미지 파일 압축 스크립트
"""

import os
from PIL import Image
import argparse

def compress_image(input_path, output_path, quality=85, max_width=1920):
    """
    이미지를 압축합니다.
    
    Args:
        input_path: 입력 이미지 경로
        output_path: 출력 이미지 경로  
        quality: JPEG 품질 (1-100)
        max_width: 최대 가로 크기
    """
    try:
        with Image.open(input_path) as img:
            print(f"원본 이미지: {input_path}")
            print(f"원본 크기: {img.size}")
            
            # RGBA를 RGB로 변환 (JPEG는 투명도 지원하지 않음)
            if img.mode in ('RGBA', 'LA'):
                # 흰색 배경으로 변환
                background = Image.new('RGB', img.size, (255, 255, 255))
                if img.mode == 'RGBA':
                    background.paste(img, mask=img.split()[-1])
                else:
                    background.paste(img, mask=img.split()[-1])
                img = background
            elif img.mode != 'RGB':
                img = img.convert('RGB')
            
            # 크기 조정 (필요한 경우)
            if img.width > max_width:
                ratio = max_width / img.width
                new_height = int(img.height * ratio)
                img = img.resize((max_width, new_height), Image.Resampling.LANCZOS)
                print(f"크기 조정됨: {img.size}")
            
            # 압축된 이미지 저장
            img.save(output_path, 'JPEG', quality=quality, optimize=True)
            
            # 파일 크기 비교
            original_size = os.path.getsize(input_path)
            compressed_size = os.path.getsize(output_path)
            compression_ratio = (original_size - compressed_size) / original_size * 100
            
            print(f"압축 완료: {output_path}")
            print(f"원본 크기: {original_size:,} bytes ({original_size/1024/1024:.1f} MB)")
            print(f"압축 크기: {compressed_size:,} bytes ({compressed_size/1024/1024:.1f} MB)")
            print(f"압축률: {compression_ratio:.1f}%")
            
            return True
            
    except Exception as e:
        print(f"❌ 압축 실패: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='단일 이미지 압축')
    parser.add_argument('input', help='입력 이미지 파일 경로')
    parser.add_argument('-o', '--output', help='출력 이미지 파일 경로')
    parser.add_argument('-q', '--quality', type=int, default=85, help='JPEG 품질 (1-100, 기본값: 85)')
    parser.add_argument('-w', '--width', type=int, default=1920, help='최대 가로 크기 (기본값: 1920)')
    
    args = parser.parse_args()
    
    if not os.path.exists(args.input):
        print(f"❌ 입력 파일을 찾을 수 없습니다: {args.input}")
        return
    
    # 출력 경로 설정
    if args.output:
        output_path = args.output
    else:
        base_name = os.path.splitext(args.input)[0]
        output_path = f"{base_name}_compressed.jpg"
    
    # 압축 실행
    print("🔧 이미지 압축 시작...")
    success = compress_image(args.input, output_path, args.quality, args.width)
    
    if success:
        print("✅ 압축이 완료되었습니다!")
    else:
        print("❌ 압축에 실패했습니다.")

if __name__ == "__main__":
    main() 