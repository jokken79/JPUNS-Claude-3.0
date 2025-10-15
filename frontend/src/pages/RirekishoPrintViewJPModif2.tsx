import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { PrinterIcon, ArrowLeftIcon } from '@heroicons/react/24/outline';

// Define the full candidate type based on the model
interface Candidate {
  id: number;
  reception_date?: string;
  arrival_date?: string;
  full_name_kanji?: string;
  full_name_kana?: string;
  full_name_roman?: string;
  gender?: string;
  date_of_birth?: string;
  nationality?: string;
  marital_status?: string;
  photo_url?: string;
  postal_code?: string;
  current_address?: string;
  phone?: string;
  mobile?: string;
  emergency_contact_name?: string;
  emergency_contact_relation?: string;
  emergency_contact_phone?: string;
  residence_status?: string;
  residence_expiry?: string;
  residence_card_number?: string;
  passport_number?: string;
  passport_expiry?: string;
  car_ownership?: string;
  voluntary_insurance?: string;
  license_number?: string;
  license_expiry?: string;
  listening_level?: string;
  speaking_level?: string;
  read_katakana?: string;
  read_hiragana?: string;
  read_kanji?: string;
  write_katakana?: string;
  write_hiragana?: string;
  write_kanji?: string;
  major?: string;
  japanese_qualification?: string;
  language_skill_exists?: string;
  jlpt_taken?: string;
  jlpt_scheduled?: string;
  antigen_test_result?: string;
  antigen_test_date?: string;
  covid_vaccine_status?: string;
  // Family information
  family_name_1?: string;
  family_relation_1?: string;
  family_age_1?: string;
  family_residence_1?: string;
  family_separate_address_1?: string;
  family_name_2?: string;
  family_relation_2?: string;
  family_age_2?: string;
  family_residence_2?: string;
  family_separate_address_2?: string;
  family_name_3?: string;
  family_relation_3?: string;
  family_age_3?: string;
  family_residence_3?: string;
  family_separate_address_3?: string;
  family_name_4?: string;
  family_relation_4?: string;
  family_age_4?: string;
  family_residence_4?: string;
  family_separate_address_4?: string;
  family_name_5?: string;
  family_relation_5?: string;
  family_age_5?: string;
  family_residence_5?: string;
  family_separate_address_5?: string;
  // Work experience
  exp_nc_lathe?: any;
  exp_forklift?: any;
  exp_car_assembly?: any;
  exp_electronic_inspection?: any;
  exp_lathe?: any;
  exp_packing?: any;
  exp_car_line?: any;
  exp_food_processing?: any;
  exp_press?: any;
  exp_welding?: any;
  exp_car_inspection?: any;
  exp_casting?: any;
  exp_line_leader?: any;
  exp_painting?: any;
  exp_other?: any;
  // Add other fields from the model as needed
}

const RirekishoPrintViewJPModif2: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const [candidate, setCandidate] = useState<Candidate | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchCandidate = async () => {
      try {
        setLoading(true);
        const token = localStorage.getItem('token');
        const response = await fetch(`/api/candidates/${id}`, {
          headers: {
            'Authorization': `Bearer ${token}`,
          },
        });

        if (!response.ok) {
          throw new Error('Failed to fetch candidate data');
        }

        const data = await response.json();
        setCandidate(data);
      } catch (error) {
        toast.error('候補者データの取得に失敗しました。');
        console.error(error);
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchCandidate();
    }
  }, [id]);

  const formatDate = (dateString?: string) => {
    if (!dateString) return { year: 0, month: 0, day: 0 };
    const date = new Date(dateString);
    return {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate(),
    };
  };

  const getCurrentDate = () => {
    const today = new Date();
    return {
      year: today.getFullYear(),
      month: today.getMonth() + 1,
      day: today.getDate(),
    };
  };

  const handlePrint = () => {
    window.print();
  };

  const handleBack = () => {
    window.history.back();
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg">読み込み中...</div>
      </div>
    );
  }

  if (!candidate) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-lg text-red-600">候補者が見つかりませんでした。</div>
      </div>
    );
  }

  const dob = formatDate(candidate.date_of_birth);
  const currentDate = getCurrentDate();

  return (
    <div className="min-h-screen bg-white">
      {/* Print Controls - Only visible on screen */}
      <div className="print:hidden bg-gray-50 p-4 border-b">
        <div className="flex justify-between items-center max-w-4xl mx-auto">
          <button
            onClick={handleBack}
            className="flex items-center gap-2 px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700"
          >
            <ArrowLeftIcon className="h-5 w-5" />
            戻る
          </button>
          <button
            onClick={handlePrint}
            className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
          >
            <PrinterIcon className="h-5 w-5" />
            印刷
          </button>
        </div>
      </div>

      {/* Print Content */}
      <div className="max-w-[210mm] mx-auto bg-white p-8">
        <style>{`
          @media print {
            body { margin: 0; }
            .print\\:hidden { display: none !important; }
          }
          
          .rirekisho-table {
            width: 100%;
            border-collapse: collapse;
            border: 2px solid black;
            font-size: 11px;
            line-height: 1.2;
          }
          
          .rirekisho-table td {
            border: 1px solid black;
            padding: 2px 4px;
            vertical-align: top;
            height: 20px;
          }
          
          .header-cell {
            background-color: #f0f0f0;
            font-weight: bold;
            text-align: center;
            font-size: 10px;
          }
          
          .name-header {
            writing-mode: vertical-rl;
            text-orientation: upright;
            width: 20px;
            background-color: #f0f0f0;
            font-weight: bold;
            text-align: center;
          }
          
          .photo-cell {
            width: 80px;
            height: 100px;
            text-align: center;
            vertical-align: middle;
          }
          
          .small-text {
            font-size: 9px;
          }
          
          .center {
            text-align: center;
          }
          
          .vertical-text {
            writing-mode: vertical-rl;
            text-orientation: upright;
          }
          
          .furigana-cell {
            width: 80px;
          }
          
          .name-cell-kana {
            height: 25px;
            font-size: 14px;
            font-weight: normal;
          }
          
          .name-cell-kanji {
            height: 30px;
            font-size: 16px;
            font-weight: bold;
          }
          
          .name-cell-roman {
            height: 25px;
            font-size: 12px;
          }
          
          .experience-cell {
            height: 60px;
            padding: 4px;
          }
        `}</style>

        <div className="print-content">
          {/* Header with date */}
          <div className="text-right mb-2 text-sm">
            令和{currentDate.year - 2018}年{currentDate.month}月{currentDate.day}日現在
          </div>

          {/* Title */}
          <div className="text-center mb-6">
            <h1 className="text-3xl font-bold tracking-wider">履　歴　書</h1>
          </div>

          {/* Main Table */}
          <table className="rirekisho-table">
            <tbody>
              {/* Row 1: Name section header */}
              <tr>
                <td rowSpan={4} className="name-header">
                  氏<br/>名
                </td>
                <td className="header-cell furigana-cell">ふりがな</td>
                <td colSpan={6} className="name-cell-kana">
                  {candidate.full_name_kana}
                </td>
                <td rowSpan={4} className="photo-cell">
                  {candidate.photo_url ? (
                    <img 
                      src={candidate.photo_url} 
                      alt="写真" 
                      className="w-full h-full object-cover border"
                    />
                  ) : (
                    <div className="w-full h-full border flex items-center justify-center bg-gray-50">
                      <span className="text-gray-400 small-text">写真を貼る位置<br/>縦4cm×横3cm</span>
                    </div>
                  )}
                </td>
              </tr>
              
              {/* Row 2: Kanji name */}
              <tr>
                <td className="small-text center">漢字</td>
                <td colSpan={6} className="name-cell-kanji">
                  {candidate.full_name_kanji}
                </td>
              </tr>
              
              {/* Row 3: Roman name */}
              <tr>
                <td className="small-text center">ローマ字</td>
                <td colSpan={6} className="name-cell-roman">
                  {candidate.full_name_roman}
                </td>
              </tr>
              
              {/* Row 4: Birth date and gender */}
              <tr>
                <td className="header-cell small-text">生年月日</td>
                <td colSpan={4}>
                  昭和・平成・<span className="font-bold">令和</span> {dob.year > 2018 ? dob.year - 2018 : ''} 年 {dob.month || ''} 月 {dob.day || ''} 日生（満　　歳）
                </td>
                <td className="header-cell small-text">男・女</td>
                <td className="center">
                  <span className={candidate.gender === '男性' || candidate.gender === 'male' ? 'font-bold' : ''}>男</span>
                  ・
                  <span className={candidate.gender === '女性' || candidate.gender === 'female' ? 'font-bold' : ''}>女</span>
                </td>
              </tr>

              {/* Address section */}
              <tr>
                <td rowSpan={2} className="name-header">
                  現<br/>住<br/>所
                </td>
                <td className="header-cell small-text">〒</td>
                <td colSpan={7}>
                  {candidate.postal_code}
                </td>
              </tr>
              <tr>
                <td className="small-text center">住所</td>
                <td colSpan={7}>
                  {candidate.current_address}
                </td>
              </tr>

              {/* Contact information */}
              <tr>
                <td className="header-cell small-text">電話</td>
                <td colSpan={4}>{candidate.phone}</td>
                <td className="header-cell small-text">携帯電話</td>
                <td colSpan={3}>{candidate.mobile}</td>
              </tr>

              {/* Nationality and status */}
              <tr>
                <td className="header-cell small-text">国籍</td>
                <td colSpan={2}>{candidate.nationality}</td>
                <td className="header-cell small-text">在留資格</td>
                <td colSpan={2}>{candidate.residence_status}</td>
                <td className="header-cell small-text">在留期限</td>
                <td colSpan={2}>{candidate.residence_expiry}</td>
              </tr>

              {/* Japanese Language Skills - Detailed Section */}
              <tr>
                <td rowSpan={8} className="name-header">
                  日<br/>本<br/>語<br/>能<br/>力
                </td>
                <td className="header-cell small-text">聞く</td>
                <td className="small-text">
                  {candidate.listening_level === 'beginner' ? '☑' : '☐'} 初級
                </td>
                <td className="small-text">
                  {candidate.listening_level === 'intermediate' ? '☑' : '☐'} 中級
                </td>
                <td className="small-text">
                  {candidate.listening_level === 'advanced' ? '☑' : '☐'} 上級
                </td>
                <td className="header-cell small-text">話す</td>
                <td className="small-text">
                  {candidate.speaking_level === 'beginner' ? '☑' : '☐'} 初級
                </td>
                <td className="small-text">
                  {candidate.speaking_level === 'intermediate' ? '☑' : '☐'} 中級
                </td>
                <td className="small-text">
                  {candidate.speaking_level === 'advanced' ? '☑' : '☐'} 上級
                </td>
              </tr>
              
              {/* Reading skills */}
              <tr>
                <td className="header-cell small-text">読む</td>
                <td className="small-text">ひらがな</td>
                <td className="small-text">{candidate.read_hiragana}</td>
                <td className="small-text">カタカナ</td>
                <td className="small-text">{candidate.read_katakana}</td>
                <td className="small-text">漢字</td>
                <td className="small-text">{candidate.read_kanji}</td>
                <td className="small-text"></td>
              </tr>
              
              {/* Writing skills */}
              <tr>
                <td className="header-cell small-text">書く</td>
                <td className="small-text">ひらがな</td>
                <td className="small-text">{candidate.write_hiragana}</td>
                <td className="small-text">カタカナ</td>
                <td className="small-text">{candidate.write_katakana}</td>
                <td className="small-text">漢字</td>
                <td className="small-text">{candidate.write_kanji}</td>
                <td className="small-text"></td>
              </tr>

              {/* JLPT Information */}
              <tr>
                <td className="header-cell small-text">日本語能力試験</td>
                <td className="small-text">N1</td>
                <td className="small-text">N2</td>
                <td className="small-text">N3</td>
                <td className="small-text">N4</td>
                <td className="small-text">N5</td>
                <td className="small-text">受験予定</td>
                <td className="small-text">{candidate.jlpt_scheduled}</td>
              </tr>

              {/* Education */}
              <tr>
                <td className="header-cell small-text">最終学歴</td>
                <td colSpan={4}>{candidate.major}</td>
                <td className="header-cell small-text">専攻</td>
                <td colSpan={3}></td>
              </tr>

              {/* Emergency Contact */}
              <tr>
                <td className="header-cell small-text">緊急連絡先</td>
                <td colSpan={3}>{candidate.emergency_contact_name}</td>
                <td className="header-cell small-text">続柄</td>
                <td>{candidate.emergency_contact_relation}</td>
                <td className="header-cell small-text">電話</td>
                <td colSpan={2}>{candidate.emergency_contact_phone}</td>
              </tr>

              {/* Family Information Header */}
              <tr>
                <td rowSpan={6} className="name-header">
                  家<br/>族<br/>構<br/>成
                </td>
                <td className="header-cell small-text">氏名</td>
                <td className="header-cell small-text">続柄</td>
                <td className="header-cell small-text">年齢</td>
                <td className="header-cell small-text">同居・別居</td>
                <td className="header-cell small-text">氏名</td>
                <td className="header-cell small-text">続柄</td>
                <td className="header-cell small-text">年齢</td>
                <td className="header-cell small-text">同居・別居</td>
              </tr>

              {/* Family Members */}
              <tr>
                <td className="small-text">{candidate.family_name_1}</td>
                <td className="small-text">{candidate.family_relation_1}</td>
                <td className="small-text center">{candidate.family_age_1}</td>
                <td className="small-text center">{candidate.family_residence_1}</td>
                <td className="small-text">{candidate.family_name_4}</td>
                <td className="small-text">{candidate.family_relation_4}</td>
                <td className="small-text center">{candidate.family_age_4}</td>
                <td className="small-text center">{candidate.family_residence_4}</td>
              </tr>
              <tr>
                <td className="small-text">{candidate.family_name_2}</td>
                <td className="small-text">{candidate.family_relation_2}</td>
                <td className="small-text center">{candidate.family_age_2}</td>
                <td className="small-text center">{candidate.family_residence_2}</td>
                <td className="small-text">{candidate.family_name_5}</td>
                <td className="small-text">{candidate.family_relation_5}</td>
                <td className="small-text center">{candidate.family_age_5}</td>
                <td className="small-text center">{candidate.family_residence_5}</td>
              </tr>
              <tr>
                <td className="small-text">{candidate.family_name_3}</td>
                <td className="small-text">{candidate.family_relation_3}</td>
                <td className="small-text center">{candidate.family_age_3}</td>
                <td className="small-text center">{candidate.family_residence_3}</td>
                <td className="small-text"></td>
                <td className="small-text"></td>
                <td className="small-text"></td>
                <td className="small-text"></td>
              </tr>

              {/* Work Experience Section */}
              <tr>
                <td rowSpan={4} className="name-header">
                  職<br/>歴<br/>・<br/>経<br/>験
                </td>
                <td colSpan={8} className="header-cell">経験作業内容</td>
              </tr>
              <tr>
                <td colSpan={8} className="small-text experience-cell">
                  <div className="grid grid-cols-2 gap-2">
                    <div>
                      <span className="inline-block w-16">NC旋盤:</span> {candidate.exp_nc_lathe}<br/>
                      <span className="inline-block w-16">旋盤:</span> {candidate.exp_lathe}<br/>
                      <span className="inline-block w-16">プレス:</span> {candidate.exp_press}<br/>
                      <span className="inline-block w-16">溶接:</span> {candidate.exp_welding}<br/>
                      <span className="inline-block w-16">フォーク:</span> {candidate.exp_forklift}<br/>
                      <span className="inline-block w-16">梱包:</span> {candidate.exp_packing}<br/>
                      <span className="inline-block w-16">塗装:</span> {candidate.exp_painting}<br/>
                      <span className="inline-block w-16">鋳造:</span> {candidate.exp_casting}
                    </div>
                    <div>
                      <span className="inline-block w-16">車組立:</span> {candidate.exp_car_assembly}<br/>
                      <span className="inline-block w-16">車ライン:</span> {candidate.exp_car_line}<br/>
                      <span className="inline-block w-16">車検査:</span> {candidate.exp_car_inspection}<br/>
                      <span className="inline-block w-16">電子検査:</span> {candidate.exp_electronic_inspection}<br/>
                      <span className="inline-block w-16">食品加工:</span> {candidate.exp_food_processing}<br/>
                      <span className="inline-block w-16">リーダー:</span> {candidate.exp_line_leader}<br/>
                      <span className="inline-block w-16">その他:</span> {candidate.exp_other}
                    </div>
                  </div>
                </td>
              </tr>

              {/* Health Information */}
              <tr>
                <td className="header-cell small-text" colSpan={2}>健康状態</td>
                <td className="header-cell small-text">抗原検査</td>
                <td className="small-text">{candidate.antigen_test_result}</td>
                <td className="header-cell small-text">実施日</td>
                <td className="small-text">{candidate.antigen_test_date}</td>
                <td className="header-cell small-text">ワクチン</td>
                <td className="small-text">{candidate.covid_vaccine_status}</td>
              </tr>
              
              <tr>
                <td className="header-cell small-text" colSpan={2}>自動車免許</td>
                <td className="small-text">{candidate.car_ownership}</td>
                <td className="header-cell small-text">免許番号</td>
                <td className="small-text" colSpan={2}>{candidate.license_number}</td>
                <td className="header-cell small-text">有効期限</td>
                <td className="small-text">{candidate.license_expiry}</td>
              </tr>
            </tbody>
          </table>

          {/* Footer */}
          <div className="text-center mt-6 small-text">
            <p>ユニバーサル企画株式会社</p>
            <p>TEL: 052-938-8840　FAX: 052-938-8841</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RirekishoPrintViewJPModif2;