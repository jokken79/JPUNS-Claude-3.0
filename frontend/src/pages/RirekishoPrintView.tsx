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
  height?: any;
  weight?: any;
  shoe_size?: any;
  dominant_hand?: any;
  clothing_size?: any;
  waist_size?: any;
  safety_shoes?: any;
  blood_type?: any;
  bento_lunch_dinner?: any;
  bento_lunch_only?: any;
  bento_dinner_only?: any;
  bento_bring_own?: any;
  commute_method?: any;
  commute_time_oneway?: any;
  family_name_1?: any;
  family_relation_1?: any;
  family_age_1?: any;
  family_residence_1?: any;
  family_separate_address_1?: any;
  family_name_2?: any;
  family_relation_2?: any;
  family_age_2?: any;
  family_residence_2?: any;
  family_separate_address_2?: any;
  family_name_3?: any;
  family_relation_3?: any;
  family_age_3?: any;
  family_residence_3?: any;
  family_separate_address_3?: any;
  family_name_4?: any;
  family_relation_4?: any;
  family_age_4?: any;
  family_residence_4?: any;
  family_separate_address_4?: any;
  family_name_5?: any;
  family_relation_5?: any;
  family_age_5?: any;
  family_residence_5?: any;
  family_separate_address_5?: any;
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

const RirekishoPrintView: React.FC = () => {
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
    if (!dateString) return { year: '', month: '', day: '' };
    const date = new Date(dateString);
    return {
      year: date.getFullYear(),
      month: date.getMonth() + 1,
      day: date.getDate(),
    };
  };

  const dob = formatDate(candidate?.date_of_birth);

  if (loading) {
    return <div className="p-8 text-center">読み込み中...</div>;
  }

  if (!candidate) {
    return <div className="p-8 text-center">候補者が見つかりません。</div>;
  }

  return (
    <div className="bg-gray-100 min-h-screen print:bg-white">
      <div className="p-4 sm:p-8 print:p-0">
        {/* Print Controls - Hidden on print */}
        <div className="mb-6 flex justify-between print:hidden">
            <button
                onClick={() => window.history.back()}
                className="flex items-center gap-2 px-4 py-2 bg-white text-gray-700 rounded-lg font-semibold text-sm hover:bg-gray-50 border transition-all"
            >
                <ArrowLeftIcon className="h-4 w-4" />
                戻る
            </button>
            <button
                onClick={() => window.print()}
                className="flex items-center gap-2 px-4 py-2 bg-indigo-600 text-white rounded-lg font-semibold text-sm hover:bg-indigo-700 transition-all"
            >
                <PrinterIcon className="h-4 w-4" />
                印刷
            </button>
        </div>

        {/* Rirekisho Paper */}
        <div className="max-w-4xl mx-auto bg-white p-6 sm:p-8 border border-gray-300 shadow-lg print:shadow-none print:border-none">
          <style>{`
            @media print {
              body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
              .print-table { border-collapse: collapse; width: 100%; font-size: 10px; }
              .print-table th, .print-table td { border: 1px solid #000; padding: 4px; vertical-align: middle; }
              .print-table th { background-color: #e0e0e0 !important; text-align: center; font-weight: normal; }
              .print-table .label { background-color: #e0e0e0 !important; text-align: center; width: 20px; }
              .print-table .value { height: 24px; }
              .print-table .value-sm { height: 20px; }
              .print-table .nested-table { width: 100%; border: none; }
              .print-table .nested-table td { border: none; padding: 0; }
            }
          `}</style>

          <div className="text-center mb-4">
            <h1 className="text-2xl font-bold">履 歴 書</h1>
          </div>

          <table className="print-table">
            <tbody>
              {/* Row 1: Reception Date, Arrival Date */}
              <tr>
                <td className="label">受付日</td>
                <td className="value" colSpan={5}>{candidate.reception_date}</td>
                <td className="label">来日</td>
                <td className="value" colSpan={5}>{candidate.arrival_date}</td>
                <td rowSpan={5} colSpan={12} className="align-top">
                    <div className="font-bold text-center border-b border-black pb-1 mb-1">日本語能力</div>
                    <div className="grid grid-cols-2 gap-x-4 text-xs px-2">
                        <div>
                            <p className="font-bold">聞く</p>
                            <p>{candidate.listening_level === 'beginner' ? '☑' : '☐'} 初級 (挨拶程度)</p>
                            <p>{candidate.listening_level === 'intermediate' ? '☑' : '☐'} 中級 (日常会話・就職可)</p>
                            <p>{candidate.listening_level === 'advanced' ? '☑' : '☐'} 上級 (通訳可)</p>
                        </div>
                        <div>
                            <p className="font-bold">話す</p>
                            <p>{candidate.speaking_level === 'beginner' ? '☑' : '☐'} 初級 (挨拶程度)</p>
                            <p>{candidate.speaking_level === 'intermediate' ? '☑' : '☐'} 中級 (日常会話・就職可)</p>
                            <p>{candidate.speaking_level === 'advanced' ? '☑' : '☐'} 上級 (通訳可)</p>
                        </div>
                    </div>
                    <div className="font-bold text-center border-b border-t border-black py-1 my-1">読む</div>
                     <div className="grid grid-cols-3 gap-x-2 text-xs px-2">
                        <p>カナ: {candidate.read_katakana}</p>
                        <p>ひら: {candidate.read_hiragana}</p>
                        <p>漢字: {candidate.read_kanji}</p>
                    </div>
                    <div className="font-bold text-center border-b border-t border-black py-1 my-1">書く</div>
                     <div className="grid grid-cols-3 gap-x-2 text-xs px-2">
                        <p>カナ: {candidate.write_katakana}</p>
                        <p>ひら: {candidate.write_hiragana}</p>
                        <p>漢字: {candidate.write_kanji}</p>
                    </div>
                </td>
              </tr>

              {/* Row 2: Name */}
              <tr>
                <td className="label" rowSpan={2}>氏名</td>
                <td className="label">フリガナ</td>
                <td className="value" colSpan={8}>{candidate.full_name_kana}</td>
                <td className="label">性別</td>
                <td className="value">{candidate.gender}</td>
              </tr>
              <tr>
                <td className="value" colSpan={9}>{candidate.full_name_kanji}</td>
                <td className="value" colSpan={2} rowSpan={3}>
                    {candidate.photo_url ? 
                        <img src={candidate.photo_url} alt="photo" className="w-full h-full object-contain" /> : 
                        <div className="w-full h-full flex items-center justify-center text-gray-400">写真</div>
                    }
                </td>
              </tr>

              {/* Row 3: Roman Name, DOB */}
              <tr>
                <td className="label">ローマ字</td>
                <td colSpan={9} className="value">{candidate.full_name_roman}</td>
              </tr>
              <tr>
                <td className="label">生年月日</td>
                <td colSpan={9} className="value">{`${dob.year} 年 ${dob.month} 月 ${dob.day} 日`}</td>
              </tr>

              {/* Row 4: Nationality, Phone */}
              <tr>
                <td className="label">国籍</td>
                <td colSpan={5} className="value">{candidate.nationality}</td>
                <td className="label">電話番号</td>
                <td colSpan={5} className="value">{candidate.phone}</td>
              </tr>

              {/* Row 5: Address */}
              <tr>
                <td className="label">郵便番号</td>
                <td colSpan={5} className="value">{candidate.postal_code}</td>
                <td className="label">携帯電話</td>
                <td colSpan={5} className="value">{candidate.mobile}</td>
                <td className="label" rowSpan={2}>最終学歴</td>
                <td className="value" colSpan={5} rowSpan={2}>{candidate.major}</td>
                <td className="label" rowSpan={2}>専攻</td>
                <td className="value" colSpan={6} rowSpan={2}></td>
              </tr>
              <tr>
                <td className="label">住所</td>
                <td colSpan={11} className="value">{candidate.current_address}</td>
              </tr>
              
              {/* Emergency Contact */}
              <tr>
                <td className="label" rowSpan={1}>緊急連絡先</td>
                <td colSpan={5} className="value">{candidate.emergency_contact_name}</td>
                <td className="label">続柄</td>
                <td colSpan={5} className="value">{candidate.emergency_contact_relation}</td>
                <td className="label">電話番号</td>
                <td colSpan={11} className="value">{candidate.emergency_contact_phone}</td>
              </tr>

              {/* Documents Section */}
              <tr>
                <td className="label" rowSpan={5}>書類関係</td>
                <td className="label">ビザ種類</td>
                <td colSpan={5} className="value">{candidate.residence_status}</td>
                <td className="label">ビザ期間</td>
                <td colSpan={5} className="value">{candidate.residence_expiry}</td>
                <td className="label" rowSpan={5}>有資格取得</td>
                <td colSpan={11} className="value">{candidate.japanese_qualification}</td>
              </tr>
              <tr>
                <td className="label">在留カード番号</td>
                <td colSpan={11} className="value">{candidate.residence_card_number}</td>
                <td colSpan={11} className="value"></td>
              </tr>
              <tr>
                <td className="label">パスポート番号</td>
                <td colSpan={5} className="value">{candidate.passport_number}</td>
                <td className="label">パスポート期限</td>
                <td colSpan={5} className="value">{candidate.passport_expiry}</td>
                <td colSpan={11} className="value"></td>
              </tr>
              <tr>
                <td className="label">自動車所有</td>
                <td colSpan={5} className="value">{candidate.car_ownership}</td>
                <td className="label">任意保険加入</td>
                <td colSpan={5} className="value">{candidate.voluntary_insurance}</td>
                <td colSpan={11} className="value"></td>
              </tr>
              <tr>
                <td className="label">運転免許種類</td>
                <td colSpan={11} className="value">{candidate.license_number}</td>
                <td colSpan={11} className="value"></td>
              </tr>

              {/* Physical Info & Bento */}
              <tr>
                <td className="label" rowSpan={2}>身体情報</td>
                <td className="label">身長</td>
                <td className="value">{candidate.height} cm</td>
                <td className="label">体重</td>
                <td className="value">{candidate.weight} kg</td>
                <td className="label">靴サイズ</td>
                <td className="value">{candidate.shoe_size} cm</td>
                <td className="label">利き腕</td>
                <td className="value">{candidate.dominant_hand}</td>
                <td colSpan={15} rowSpan={4}></td>
              </tr>
              <tr>
                <td className="label">服のサイズ</td>
                <td className="value">{candidate.clothing_size}</td>
                <td className="label">ウエスト</td>
                <td className="value">{candidate.waist_size} cm</td>
                <td className="label">安全靴</td>
                <td className="value">{candidate.safety_shoes}</td>
                <td className="label">血液型</td>
                <td className="value">{candidate.blood_type}</td>
              </tr>
              <tr>
                <td className="label">お弁当</td>
                <td colSpan={8} className="value">
                    昼/夜: {candidate.bento_lunch_dinner}  昼のみ: {candidate.bento_lunch_only} 夜のみ: {candidate.bento_dinner_only} 持参: {candidate.bento_bring_own}
                </td>
              </tr>
              <tr>
                <td className="label">通勤</td>
                <td className="label">通勤方法</td>
                <td colSpan={3} className="value">{candidate.commute_method}</td>
                <td className="label">片道時間</td>
                <td colSpan={3} className="value">{candidate.commute_time_oneway} 分</td>
              </tr>

              {/* Family Composition */}
              <tr>
                <td className="label" rowSpan={2}>家族構成</td>
                <td className="label">氏名</td>
                <td className="label">続柄</td>
                <td className="label">年齢</td>
                <td className="label">居住</td>
                <td className="label">別居住住所</td>
                <td className="label" rowSpan={6}>職歴</td>
                <td colSpan={17} rowSpan={6} className="value"></td>
              </tr>
              <tr>
                <td className="value">{candidate.family_name_1}</td>
                <td className="value">{candidate.family_relation_1}</td>
                <td className="value">{candidate.family_age_1}</td>
                <td className="value">{candidate.family_residence_1}</td>
                <td className="value">{candidate.family_separate_address_1}</td>
              </tr>
              <tr>
                 <td className="label" rowSpan={4}></td>
                 <td className="value">{candidate.family_name_2}</td>
                 <td className="value">{candidate.family_relation_2}</td>
                 <td className="value">{candidate.family_age_2}</td>
                 <td className="value">{candidate.family_residence_2}</td>
                 <td className="value">{candidate.family_separate_address_2}</td>
              </tr>
               <tr>
                 <td className="value">{candidate.family_name_3}</td>
                 <td className="value">{candidate.family_relation_3}</td>
                 <td className="value">{candidate.family_age_3}</td>
                 <td className="value">{candidate.family_residence_3}</td>
                 <td className="value">{candidate.family_separate_address_3}</td>
              </tr>
               <tr>
                 <td className="value">{candidate.family_name_4}</td>
                 <td className="value">{candidate.family_relation_4}</td>
                 <td className="value">{candidate.family_age_4}</td>
                 <td className="value">{candidate.family_residence_4}</td>
                 <td className="value">{candidate.family_separate_address_4}</td>
              </tr>
               <tr>
                 <td className="value">{candidate.family_name_5}</td>
                 <td className="value">{candidate.family_relation_5}</td>
                 <td className="value">{candidate.family_age_5}</td>
                 <td className="value">{candidate.family_residence_5}</td>
                 <td className="value">{candidate.family_separate_address_5}</td>
              </tr>

              {/* Work Experience */}
              <tr>
                <td className="label" colSpan={24}>経験作業内容</td>
              </tr>
              <tr>
                <td colSpan={24} className="value text-xs p-2">
                    <div className="grid grid-cols-4 gap-x-4">
                        <p>NC旋盤: {candidate.exp_nc_lathe}</p>
                        <p>フォークリフト: {candidate.exp_forklift}</p>
                        <p>車部品組立: {candidate.exp_car_assembly}</p>
                        <p>電子部品検査: {candidate.exp_electronic_inspection}</p>
                        <p>旋盤: {candidate.exp_lathe}</p>
                        <p>梱包: {candidate.exp_packing}</p>
                        <p>車部品ライン: {candidate.exp_car_line}</p>
                        <p>食品加工: {candidate.exp_food_processing}</p>
                        <p>プレス: {candidate.exp_press}</p>
                        <p>溶接: {candidate.exp_welding}</p>
                        <p>車部品検査: {candidate.exp_car_inspection}</p>
                        <p>鋳造: {candidate.exp_casting}</p>
                        <p>ラインリーダー: {candidate.exp_line_leader}</p>
                        <p>塗装: {candidate.exp_painting}</p>
                        <p>その他: {candidate.exp_other}</p>
                    </div>
                </td>
              </tr>

            </tbody>
          </table>

          <div className="text-center mt-4">
            <p className="text-sm">ユニバーサル企画株式会社</p>
            <p className="text-xs">TEL 052-938-8840 FAX 052-938-8841</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RirekishoPrintView;