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

const RirekishoPrintViewJPModif: React.FC = () => {
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
  
  const calculateAge = (birthday?: string) => {
    if (!birthday) return '';
    const birthDate = new Date(birthday);
    const today = new Date();
    let age = today.getFullYear() - birthDate.getFullYear();
    const m = today.getMonth() - birthDate.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birthDate.getDate())) {
        age--;
    }
    return age;
  }

  const dob = formatDate(candidate?.date_of_birth);
  const age = calculateAge(candidate?.date_of_birth);

  if (loading) {
    return <div className="p-8 text-center">読み込み中...</div>;
  }

  if (!candidate) {
    return <div className="p-8 text-center">候補者が見つかりません。</div>;
  }

  const Checkbox = ({ checked }: { checked: boolean }) => (
    <span className="inline-block w-4 h-4 border border-black text-center leading-4">
        {checked ? '✔' : ''}
    </span>
  );

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
        <div className="max-w-4xl mx-auto bg-white p-4 border border-gray-300 shadow-lg print:shadow-none print:border-none font-serif">
          <style>{`
            @media print {
              body { -webkit-print-color-adjust: exact; print-color-adjust: exact; }
              .print-table { border-collapse: collapse; width: 100%; font-size: 11px; }
              .print-table th, .print-table td { border: 1px solid #000; padding: 2px 4px; vertical-align: middle; }
              .print-table .label { background-color: #e0e0e0 !important; text-align: center; font-weight: normal; }
              .print-table .value { height: 22px; }
              .print-table .value-sm { height: 18px; }
              .print-table .br-none { border-right: none !important; }
              .print-table .bl-none { border-left: none !important; }
              .print-table .bt-none { border-top: none !important; }
              .print-table .bb-none { border-bottom: none !important; }
            }
          `}</style>

          <div className="text-center mb-2">
            <h1 className="text-2xl font-bold">履 歴 書</h1>
          </div>

          <table className="w-full border-collapse border border-black text-xs print-table">
            <tbody>
              {/* Header Info */}
              <tr>
                <td className="label w-[8%]">受付日</td>
                <td className="w-[12%]">{formatDate(candidate.reception_date).year}</td>
                <td className="label w-[4%]">年</td>
                <td className="w-[8%]">{formatDate(candidate.reception_date).month}</td>
                <td className="label w-[4%]">月</td>
                <td className="w-[8%]">{formatDate(candidate.reception_date).day}</td>
                <td className="label w-[4%]">日</td>
                <td className="w-[1%]"></td>
                <td className="label w-[8%]">来日</td>
                <td className="w-[12%]">{formatDate(candidate.arrival_date).year}</td>
                <td className="label w-[4%]">年</td>
                <td className="w-[8%]">{formatDate(candidate.arrival_date).month}</td>
                <td className="label w-[4%]">月</td>
                <td className="w-[8%]">{formatDate(candidate.arrival_date).day}</td>
                <td className="label w-[4%]">日</td>
              </tr>

              {/* Personal Info */}
              <tr>
                <td className="label" rowSpan={4}>氏名</td>
                <td className="label">フリガナ</td>
                <td colSpan={5}>{candidate.full_name_kana}</td>
                <td className="label">性別</td>
                <td colSpan={7}>{candidate.gender}</td>
              </tr>
              <tr>
                <td rowSpan={3} colSpan={6} className="text-xl align-middle text-center">{candidate.full_name_kanji}</td>
                <td colSpan={8} rowSpan={3} className="p-0">
                    {candidate.photo_url ? 
                        <img src={candidate.photo_url} alt="photo" className="w-full h-full object-cover" /> : 
                        <div className="w-full h-full flex items-center justify-center text-gray-400">写真</div>
                    }
                </td>
              </tr>
              <tr></tr>
              <tr></tr>
              
              <tr>
                <td className="label">ローマ字</td>
                <td colSpan={6}>{candidate.full_name_roman}</td>
                <td className="label">生年月日</td>
                <td colSpan={7}>{`${dob.year} 年 ${dob.month} 月 ${dob.day} 日 (${age}歳)`}</td>
              </tr>

              <tr>
                <td className="label">国籍</td>
                <td colSpan={6}>{candidate.nationality}</td>
                <td className="label">電話番号</td>
                <td colSpan={7}>{candidate.phone}</td>
              </tr>

              <tr>
                <td className="label">郵便番号</td>
                <td colSpan={6}>{candidate.postal_code}</td>
                <td className="label">携帯電話</td>
                <td colSpan={7}>{candidate.mobile}</td>
              </tr>
              
              <tr>
                <td className="label">住所</td>
                <td colSpan={14}>{candidate.current_address}</td>
              </tr>

              <tr>
                <td className="label">緊急連絡先</td>
                <td colSpan={4}>{candidate.emergency_contact_name}</td>
                <td className="label">続柄</td>
                <td colSpan={3}>{candidate.emergency_contact_relation}</td>
                <td className="label">電話番号</td>
                <td colSpan={5}>{candidate.emergency_contact_phone}</td>
              </tr>

              {/* Documents */}
              <tr>
                <td className="label" rowSpan={5}>書類関係</td>
                <td className="label">ビザ種類</td>
                <td colSpan={5}>{candidate.residence_status}</td>
                <td className="label">自動車所有</td>
                <td colSpan={3}>{candidate.car_ownership}</td>
                <td className="label">任意保険加入</td>
                <td colSpan={3}>{candidate.voluntary_insurance}</td>
              </tr>
              <tr>
                <td className="label">ビザ期間</td>
                <td colSpan={5}>{formatDate(candidate.residence_expiry).year}年{formatDate(candidate.residence_expiry).month}月{formatDate(candidate.residence_expiry).day}日</td>
                <td className="label" rowSpan={2}>運転免許<br/>種類</td>
                <td colSpan={7} rowSpan={2}>{candidate.license_number}</td>
              </tr>
              <tr>
                <td className="label">在留カード番号</td>
                <td colSpan={5}>{candidate.residence_card_number}</td>
              </tr>
              <tr>
                <td className="label">パスポート番号</td>
                <td colSpan={5}>{candidate.passport_number}</td>
                <td className="label">運転免許番号<br/>及び条件</td>
                <td colSpan={7}>{candidate.license_number}</td>
              </tr>
              <tr>
                <td className="label">パスポート期限</td>
                <td colSpan={5}>{formatDate(candidate.passport_expiry).year}年{formatDate(candidate.passport_expiry).month}月{formatDate(candidate.passport_expiry).day}日</td>
                <td className="label">運転免許期限</td>
                <td colSpan={7}>{formatDate(candidate.license_expiry).year}年{formatDate(candidate.license_expiry).month}月{formatDate(candidate.license_expiry).day}日</td>
              </tr>

              {/* Body Info */}
              <tr>
                <td className="label" rowSpan={2}>身体情報寸法</td>
                <td className="label">身長</td>
                <td>{candidate.height} cm</td>
                <td className="label">体重</td>
                <td>{candidate.weight} kg</td>
                <td className="label">靴サイズ</td>
                <td>{candidate.shoe_size} cm</td>
                <td className="label">利き腕</td>
                <td colSpan={2}>{candidate.dominant_hand}</td>
                <td className="label" rowSpan={5}>職歴</td>
                <td colSpan={4} rowSpan={5}></td>
              </tr>
              <tr>
                <td className="label">服のサイズ</td>
                <td>{candidate.clothing_size}</td>
                <td className="label">ウエスト</td>
                <td>{candidate.waist_size} cm</td>
                <td className="label">安全靴</td>
                <td>{candidate.safety_shoes}</td>
                <td className="label">血液型</td>
                <td colSpan={2}>{candidate.blood_type}</td>
              </tr>
              <tr>
                <td className="label" rowSpan={2}>お弁当<br/>(社内食堂)</td>
                <td colSpan={4}><Checkbox checked={!!candidate.bento_lunch_dinner} /> お弁当 昼/夜</td>
                <td colSpan={5}><Checkbox checked={!!candidate.bento_lunch_only} /> お弁当 昼のみ</td>
                <td colSpan={5} rowSpan={2}></td>
              </tr>
              <tr>
                <td colSpan={4}><Checkbox checked={!!candidate.bento_dinner_only} /> お弁当 夜のみ</td>
                <td colSpan={5}><Checkbox checked={!!candidate.bento_bring_own} /> お弁当持参</td>
              </tr>
              <tr>
                <td className="label">通勤片道時間</td>
                <td colSpan={9}>{candidate.commute_time_oneway} 分</td>
              </tr>

              {/* Family */}
              <tr>
                <td className="label" rowSpan={2}>家族構成</td>
                <td className="label">氏名</td>
                <td className="label">続柄</td>
                <td className="label">年齢</td>
                <td className="label">居住</td>
                <td className="label" colSpan={2}>配偶者</td>
                <td className="label" colSpan={8}>居住住所</td>
              </tr>
              <tr>
                <td>{candidate.family_name_1}</td>
                <td>{candidate.family_relation_1}</td>
                <td>{candidate.family_age_1}</td>
                <td>{candidate.family_residence_1}</td>
                <td colSpan={2}></td>
                <td colSpan={8}>{candidate.family_separate_address_1}</td>
              </tr>

              {/* Experience */}
              <tr>
                <td colSpan={15} className="label">経験作業内容</td>
              </tr>
              <tr>
                <td colSpan={15} className="p-1">
                    <div className="grid grid-cols-4 gap-1 text-xs">
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_nc_lathe} /> NC旋盤</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_lathe} /> 旋盤</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_press} /> ﾌﾟﾚｽ</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_forklift} /> ﾌｫｰｸﾘﾌﾄ</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_packing} /> 梱包</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_welding} /> 溶接</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_car_assembly} /> 車部品組立</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_car_line} /> 車部品ライン</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_car_inspection} /> 車部品検査</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_electronic_inspection} /> 電子部品検査</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_food_processing} /> 食品加工</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_casting} /> 鋳造</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_line_leader} /> ラインリーダー</div>
                        <div className="flex items-center"><Checkbox checked={!!candidate.exp_painting} /> 塗装</div>
                    </div>
                    <div className="mt-1">その他: {candidate.exp_other}</div>
                </td>
              </tr>
            </tbody>
          </table>
          
          <div className="flex justify-between items-end mt-2">
            <div>
                <img src="/uns-logo.gif" alt="UNS-kikaku Logo" className="h-8" />
            </div>
            <div className="text-right text-xs">
                <p className="font-bold">ユニバーサル企画株式会社</p>
                <p>TEL 052-938-8840 FAX 052-938-8841</p>
            </div>
            <div className="text-xs">
                ID: ..........................
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default RirekishoPrintViewJPModif;
