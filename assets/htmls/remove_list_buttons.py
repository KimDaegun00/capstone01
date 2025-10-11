#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import re
import glob

def remove_list_buttons_from_html(file_path):
    """HTML 파일에서 목록 버튼과 관련 함수를 제거합니다."""
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # 1. fn_goBack 함수 제거
        # 함수 정의 패턴: function fn_goBack() { ... }
        fn_goBack_pattern = r'\s*function fn_goBack\(\)\s*\{[^}]*\$\([^}]*\}[^}]*\}\s*'
        content = re.sub(fn_goBack_pattern, '', content, flags=re.DOTALL)
        
        # 2. 목록 버튼과 감싸는 div 제거
        # 버튼을 포함한 전체 div 패턴
        button_div_pattern = r'<div class="txtC w100 mT10 mB-50">\s*<button type="button" class="btn-blue" onclick="fn_goBack\(\)"><i class="xi-list mR5 mB5"></i>목록</button>\s*</div>'
        content = re.sub(button_div_pattern, '', content, flags=re.DOTALL)
        
        # 3. 혹시 남아있을 수 있는 개별 버튼도 제거
        button_pattern = r'<button type="button" class="btn-blue" onclick="fn_goBack\(\)"><i class="xi-list mR5 mB5"></i>목록</button>'
        content = re.sub(button_pattern, '', content)
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ 수정됨: {os.path.basename(file_path)}")
            return True
        else:
            print(f"⏭️  변경사항 없음: {os.path.basename(file_path)}")
            return False
            
    except Exception as e:
        print(f"❌ 오류 발생 {os.path.basename(file_path)}: {e}")
        return False

def main():
    """메인 함수"""
    html_dir = "assets/htmls"
    
    if not os.path.exists(html_dir):
        print(f"❌ 디렉토리를 찾을 수 없습니다: {html_dir}")
        return
    
    # HTML 파일 목록 가져오기
    html_files = glob.glob(os.path.join(html_dir, "*.html"))
    
    if not html_files:
        print(f"❌ {html_dir}에 HTML 파일이 없습니다.")
        return
    
    print(f"🔍 {len(html_files)}개의 HTML 파일을 처리합니다...")
    print("=" * 50)
    
    modified_count = 0
    
    for html_file in sorted(html_files):
        if remove_list_buttons_from_html(html_file):
            modified_count += 1
    
    print("=" * 50)
    print(f"🎉 처리 완료! {modified_count}개 파일이 수정되었습니다.")

if __name__ == "__main__":
    main()
