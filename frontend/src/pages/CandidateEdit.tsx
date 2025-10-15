import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { toast } from 'react-hot-toast';
import { faker } from '@faker-js/faker';
import OCRUploader from '../components/OCRUploader';
import { InformationCircleIcon } from '@heroicons/react/24/outline';

// A simplified candidate type for the form state
type CandidateFormData = {
  [key: string]: any;
  full_name_kanji?: string;
  full_name_kana?: string;
  // ... other fields will be added here
};

const CandidateForm: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [candidate, setCandidate] = useState<CandidateFormData>({});
  const [loading, setLoading] = useState(false);
  const [isNew, setIsNew] = useState(true);
  const [showOCRUploader, setShowOCRUploader] = useState(false);

  useEffect(() => {
    if (id) {
      setIsNew(false);
      setLoading(true);
      const fetchCandidate = async () => {
        try {
          const token = localStorage.getItem('token');
          const response = await fetch(`/api/candidates/${id}`, {
            headers: { 'Authorization': `Bearer ${token}` },
          });
          if (!response.ok) throw new Error('Failed to fetch candidate');
          const data = await response.json();
          setCandidate(data);
        } catch (error) {
          toast.error('候補者データの読み込みに失敗しました。');
        } finally {
          setLoading(false);
        }
      };
      fetchCandidate();
    }
  }, [id]);

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setCandidate(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    const url = isNew ? '/api/candidates/' : `/api/candidates/${id}`;
    const method = isNew ? 'POST' : 'PUT';

    try {
      const token = localStorage.getItem('token');
      const response = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
        body: JSON.stringify(candidate),
      });

      if (!response.ok) {
        // Try to get more detailed error from backend
        const errorData = await response.json();
        throw new Error(errorData.detail || 'サーバーエラーが発生しました。');
      }

      const savedCandidate = await response.json();
      toast.success(isNew ? '候補者を正常に作成しました。' : '候補者を正常に更新しました。');

      // If we're on the edit page already, stay here
      if (isNew) {
        navigate(`/candidates/${savedCandidate.id}`);
      }

    } catch (error: any) {
      toast.error(`保存に失敗しました: ${error.message}`);
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleOCRComplete = (ocrData: any) => {
    // Mapping from OCR data to candidate fields
    const mappedData: Partial<CandidateFormData> = {};

    // Names (support multiple aliases coming from OCR service)
    const fullNameKanji = ocrData.full_name_kanji || ocrData.name_kanji;
    const fullNameKana = ocrData.full_name_kana || ocrData.name_kana;
    const fullNameRoman = ocrData.full_name_roman || ocrData.name_roman;
    if (fullNameKanji) mappedData.full_name_kanji = fullNameKanji;
    if (fullNameKana) mappedData.full_name_kana = fullNameKana;
    if (fullNameRoman) mappedData.full_name_roman = fullNameRoman;

    // Contact info
    if (ocrData.phone || ocrData.phone_number) mappedData.phone = ocrData.phone || ocrData.phone_number;
    if (ocrData.email) mappedData.email = ocrData.email;

    // Address data
    const detectedAddress = ocrData.current_address || ocrData.address || ocrData.registered_address;
    if (detectedAddress) {
      mappedData.current_address = detectedAddress;
      mappedData.address = detectedAddress;
    }
    if (ocrData.postal_code) mappedData.postal_code = ocrData.postal_code;
    if (ocrData.address_banchi || ocrData.banchi) mappedData.address_banchi = ocrData.address_banchi || ocrData.banchi;
    if (ocrData.address_building || ocrData.building)
      mappedData.address_building = ocrData.address_building || ocrData.building;

    // Special mappings
    const dateOfBirth = ocrData.date_of_birth || ocrData.birthday;
    if (dateOfBirth) mappedData.date_of_birth = dateOfBirth;
    if (ocrData.gender) mappedData.gender = ocrData.gender;

    // Mapping for Zairyu Card specific fields
    if (ocrData.nationality) mappedData.nationality = ocrData.nationality;
    const residenceStatus = ocrData.residence_status || ocrData.visa_status;
    if (residenceStatus) mappedData.residence_status = residenceStatus;
    const residenceExpiry = ocrData.residence_expiry || ocrData.zairyu_expire_date;
    if (residenceExpiry) mappedData.residence_expiry = residenceExpiry;
    const residenceCardNumber = ocrData.residence_card_number || ocrData.zairyu_card_number;
    if (residenceCardNumber) mappedData.residence_card_number = residenceCardNumber;

    // For driver's license
    if (ocrData.license_number) mappedData.license_number = ocrData.license_number;
    const licenseExpiry = ocrData.license_expiry || ocrData.license_expire_date;
    if (licenseExpiry) mappedData.license_expiry = licenseExpiry;

    // Photo (data URI)
    const photoUrl = ocrData.photo_url || ocrData.photo;
    if (photoUrl) mappedData.photo_url = photoUrl;

    // Update the form with OCR extracted data
    setCandidate(prev => ({
      ...prev,
      ...mappedData
    }));

    // Show notification
    toast.success('OCRデータをフォームに適用しました。内容を確認して必要に応じて編集してください。');

    // Hide OCR uploader after successful processing
    setShowOCRUploader(false);
  };

  const fillWithDummyData = () => {
    setCandidate({
      full_name_kanji: faker.person.fullName(),
      full_name_kana: faker.person.fullName(),
      full_name_roman: faker.person.fullName(),
      date_of_birth: faker.date.past({ years: 30 }).toISOString().split('T')[0],
      gender: ['男性', '女性'][Math.floor(Math.random() * 2)],
      nationality: faker.location.country(),
      postal_code: faker.location.zipCode(),
      current_address: faker.location.streetAddress(),
      phone: faker.phone.number(),
      mobile: faker.phone.number(),
      email: faker.internet.email(),
      residence_status: faker.lorem.word(),
      residence_expiry: faker.date.future({ years: 1 }).toISOString().split('T')[0],
      residence_card_number: faker.string.alphanumeric(12).toUpperCase(),
      passport_number: faker.string.alphanumeric(9).toUpperCase(),
      passport_expiry: faker.date.future({ years: 5 }).toISOString().split('T')[0],
      license_number: faker.string.alphanumeric(12).toUpperCase(),
      license_expiry: faker.date.future({ years: 2 }).toISOString().split('T')[0],
      listening_level: ['beginner', 'intermediate', 'advanced'][Math.floor(Math.random() * 3)],
      speaking_level: ['beginner', 'intermediate', 'advanced'][Math.floor(Math.random() * 3)],
      reading_level: 'N2',
      writing_level: 'N3',
      exp_nc_lathe: faker.datatype.boolean(),
      exp_lathe: faker.datatype.boolean(),
      exp_press: faker.datatype.boolean(),
      exp_forklift: faker.datatype.boolean(),
      exp_packing: faker.datatype.boolean(),
      exp_welding: faker.datatype.boolean(),
      exp_car_assembly: faker.datatype.boolean(),
      exp_car_line: faker.datatype.boolean(),
      exp_car_inspection: faker.datatype.boolean(),
      exp_electronic_inspection: faker.datatype.boolean(),
      exp_food_processing: faker.datatype.boolean(),
      exp_casting: faker.datatype.boolean(),
      exp_line_leader: faker.datatype.boolean(),
      exp_painting: faker.datatype.boolean(),
      exp_other: faker.lorem.sentence(),
    });
  };

  if (loading && !isNew) {
    return <div>読み込み中...</div>;
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-8">
      <div className="bg-white p-8 rounded-lg shadow-md">
        <div className="flex justify-between items-center mb-6">
          <h2 className="text-2xl font-bold text-gray-800">履歴書フォーム</h2>
          <div>
            <button
              type="button"
              onClick={() => setShowOCRUploader(!showOCRUploader)}
              className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-purple-600 hover:bg-purple-700 mr-2"
            >
              {showOCRUploader ? 'OCRアップローダーを閉じる' : 'OCRでドキュメントをスキャン'}
            </button>
            <button type="button" onClick={fillWithDummyData} className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-green-600 hover:bg-green-700 mr-2">
              Fill with Dummy Data
            </button>
            <button type="button" onClick={() => setCandidate({})} className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-red-600 hover:bg-red-700 mr-2">
              Clear Form
            </button>
            <button type="button" onClick={() => navigator.clipboard.writeText(JSON.stringify(candidate, null, 2))} className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 mr-2">
              Copy JSON
            </button>
            <button type="button" onClick={() => console.log(candidate)} className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-gray-600 hover:bg-gray-700">
              Log Candidate
            </button>
          </div>
        </div>

        {/* OCR Uploader */}
        {showOCRUploader && (
          <div className="mb-6">
            <OCRUploader onOCRComplete={handleOCRComplete} />
            <div className="mt-4 p-4 bg-blue-50 rounded-md flex items-start">
              <InformationCircleIcon className="h-6 w-6 text-blue-500 mr-2 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-700">
                <p className="font-medium">OCRについて</p>
                <p>履歴書や在留カードなどのドキュメントをアップロードすると、システムが自動的に情報を抽出してフォームに入力します。抽出された情報は必ず確認し、必要に応じて修正してください。</p>
              </div>
            </div>
          </div>
        )}

        {/* Personal Information Section */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div>
                <label htmlFor="full_name_kanji" className="block text-sm font-medium text-gray-700">氏名 (Kanji)</label>
                <input
                    type="text"
                    name="full_name_kanji"
                    id="full_name_kanji"
                    value={candidate.full_name_kanji || ''}
                    onChange={handleInputChange}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
            </div>
            <div>
                <label htmlFor="full_name_kana" className="block text-sm font-medium text-gray-700">フリガナ (Kana)</label>
                <input
                    type="text"
                    name="full_name_kana"
                    id="full_name_kana"
                    value={candidate.full_name_kana || ''}
                    onChange={handleInputChange}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                />
            </div>
        </div>

        {/* More Personal Info */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
            <div>
                <label htmlFor="full_name_roman" className="block text-sm font-medium text-gray-700">氏名 (Roman)</label>
                <input type="text" name="full_name_roman" id="full_name_roman" value={candidate.full_name_roman || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="date_of_birth" className="block text-sm font-medium text-gray-700">生年月日 (Date of Birth)</label>
                <input type="date" name="date_of_birth" id="date_of_birth" value={candidate.date_of_birth?.split('T')[0] || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="gender" className="block text-sm font-medium text-gray-700">性別 (Gender)</label>
                <select name="gender" id="gender" value={candidate.gender || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
                    <option value="">選択してください</option>
                    <option value="男性">男性 (Male)</option>
                    <option value="女性">女性 (Female)</option>
                </select>
            </div>
            <div>
                <label htmlFor="nationality" className="block text-sm font-medium text-gray-700">国籍 (Nationality)</label>
                <input type="text" name="nationality" id="nationality" value={candidate.nationality || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
        </div>

        {/* Address & Contact */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
            <div>
                <label htmlFor="postal_code" className="block text-sm font-medium text-gray-700">郵便番号 (Postal Code)</label>
                <input type="text" name="postal_code" id="postal_code" value={candidate.postal_code || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="current_address" className="block text-sm font-medium text-gray-700">現住所 (Current Address)</label>
                <input type="text" name="current_address" id="current_address" value={candidate.current_address || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="phone" className="block text-sm font-medium text-gray-700">電話番号 (Phone)</label>
                <input type="text" name="phone" id="phone" value={candidate.phone || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="mobile" className="block text-sm font-medium text-gray-700">携帯電話 (Mobile)</label>
                <input type="text" name="mobile" id="mobile" value={candidate.mobile || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="fax_number" className="block text-sm font-medium text-gray-700">ファックス番号 (Fax)</label>
                <input type="text" name="fax_number" id="fax_number" value={candidate.fax_number || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
            <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700">メールアドレス (Email)</label>
                <input type="email" name="email" id="email" value={candidate.email || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
            </div>
        </div>

        {/* Documents Section */}
        <div className="mt-10">
            <h3 className="text-lg font-medium leading-6 text-gray-900">書類関係 (Documents)</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-4">
                <div>
                    <label htmlFor="residence_status" className="block text-sm font-medium text-gray-700">在留資格 (Visa Status)</label>
                    <input type="text" name="residence_status" id="residence_status" value={candidate.residence_status || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                <div>
                    <label htmlFor="residence_expiry" className="block text-sm font-medium text-gray-700">在留期限 (Visa Expiry)</label>
                    <input type="date" name="residence_expiry" id="residence_expiry" value={candidate.residence_expiry?.split('T')[0] || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                <div className="md:col-span-2">
                    <label htmlFor="residence_card_number" className="block text-sm font-medium text-gray-700">在留カード番号 (Residence Card No.)</label>
                    <input type="text" name="residence_card_number" id="residence_card_number" value={candidate.residence_card_number || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                <div>
                    <label htmlFor="passport_number" className="block text-sm font-medium text-gray-700">パスポート番号 (Passport No.)</label>
                    <input type="text" name="passport_number" id="passport_number" value={candidate.passport_number || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                <div>
                    <label htmlFor="passport_expiry" className="block text-sm font-medium text-gray-700">パスポート期限 (Passport Expiry)</label>
                    <input type="date" name="passport_expiry" id="passport_expiry" value={candidate.passport_expiry?.split('T')[0] || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                 <div>
                    <label htmlFor="license_number" className="block text-sm font-medium text-gray-700">運転免許番号 (Driver's License No.)</label>
                    <input type="text" name="license_number" id="license_number" value={candidate.license_number || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
                <div>
                    <label htmlFor="license_expiry" className="block text-sm font-medium text-gray-700">運転免許期限 (License Expiry)</label>
                    <input type="date" name="license_expiry" id="license_expiry" value={candidate.license_expiry?.split('T')[0] || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" />
                </div>
            </div>
        </div>

        {/* Japanese Language Ability Section */}
        <div className="mt-10">
            <h3 className="text-lg font-medium leading-6 text-gray-900">日本語能力 (Japanese Language Ability)</h3>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mt-4">
                <div>
                    <label htmlFor="listening_level" className="block text-sm font-medium text-gray-700">聞く (Listening)</label>
                    <select name="listening_level" id="listening_level" value={candidate.listening_level || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
                        <option value="">選択してください</option>
                        <option value="beginner">初級 (Beginner)</option>
                        <option value="intermediate">中級 (Intermediate)</option>
                        <option value="advanced">上級 (Advanced)</option>
                    </select>
                </div>
                <div>
                    <label htmlFor="speaking_level" className="block text-sm font-medium text-gray-700">話す (Speaking)</label>
                    <select name="speaking_level" id="speaking_level" value={candidate.speaking_level || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm">
                        <option value="">選択してください</option>
                        <option value="beginner">初級 (Beginner)</option>
                        <option value="intermediate">中級 (Intermediate)</option>
                        <option value="advanced">上級 (Advanced)</option>
                    </select>
                </div>
                <div>
                    <label htmlFor="reading_level" className="block text-sm font-medium text-gray-700">読む (Reading)</label>
                    <input type="text" name="reading_level" id="reading_level" value={candidate.reading_level || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" placeholder="例: N2"/>
                </div>
                <div>
                    <label htmlFor="writing_level" className="block text-sm font-medium text-gray-700">書く (Writing)</label>
                    <input type="text" name="writing_level" id="writing_level" value={candidate.writing_level || ''} onChange={handleInputChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm" placeholder="例: N3"/>
                </div>
            </div>
        </div>

        {/* Work Experience Section */}
        <div className="mt-10">
            <h3 className="text-lg font-medium leading-6 text-gray-900">経験作業内容 (Work Experience)</h3>
            <div className="mt-4 grid grid-cols-2 md:grid-cols-4 gap-4">
                {
                    [
                        { name: 'exp_nc_lathe', label: 'NC旋盤' },
                        { name: 'exp_lathe', label: '旋盤' },
                        { name: 'exp_press', label: 'ﾌﾟﾚｽ' },
                        { name: 'exp_forklift', label: 'ﾌｫｰｸﾘﾌﾄ' },
                        { name: 'exp_packing', label: '梱包' },
                        { name: 'exp_welding', label: '溶接' },
                        { name: 'exp_car_assembly', label: '車部品組立' },
                        { name: 'exp_car_line', label: '車部品ライン' },
                        { name: 'exp_car_inspection', label: '車部品検査' },
                        { name: 'exp_electronic_inspection', label: '電子部品検査' },
                        { name: 'exp_food_processing', label: '食品加工' },
                        { name: 'exp_casting', label: '鋳造' },
                        { name: 'exp_line_leader', label: 'ラインリーダー' },
                        { name: 'exp_painting', label: '塗装' },
                    ].map(exp => (
                        <div key={exp.name} className="flex items-center">
                            <input
                                id={exp.name}
                                name={exp.name}
                                type="checkbox"
                                checked={!!candidate[exp.name]}
                                onChange={e => setCandidate(prev => ({ ...prev, [exp.name]: e.target.checked }))}
                                className="h-4 w-4 rounded border-gray-300 text-indigo-600 focus:ring-indigo-500"
                            />
                            <label htmlFor={exp.name} className="ml-2 block text-sm text-gray-900">{exp.label}</label>
                        </div>
                    ))
                }
            </div>
            <div className="mt-4">
                 <label htmlFor="exp_other" className="block text-sm font-medium text-gray-700">その他 (Other)</label>
                 <textarea
                    name="exp_other"
                    id="exp_other"
                    value={candidate.exp_other || ''}
                    onChange={handleInputChange}
                    rows={3}
                    className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                 />
            </div>
        </div>

        {/* Emergency Contact Section */}
        <div className="mt-10">
            <h3 className="text-lg font-medium leading-6 text-gray-900">緊急連絡先 (Emergency Contact)</h3>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-6 mt-4">
                <div>
                    <label htmlFor="emergency_contact_name" className="block text-sm font-medium text-gray-700">氏名 (Name)</label>
                    <input
                        type="text"
                        name="emergency_contact_name"
                        id="emergency_contact_name"
                        value={candidate.emergency_contact_name || ''}
                        onChange={handleInputChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    />
                </div>
                <div>
                    <label htmlFor="emergency_contact_relation" className="block text-sm font-medium text-gray-700">続柄 (Relation)</label>
                    <input
                        type="text"
                        name="emergency_contact_relation"
                        id="emergency_contact_relation"
                        value={candidate.emergency_contact_relation || ''}
                        onChange={handleInputChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    />
                </div>
                <div>
                    <label htmlFor="emergency_contact_phone" className="block text-sm font-medium text-gray-700">電話番号 (Phone)</label>
                    <input
                        type="text"
                        name="emergency_contact_phone"
                        id="emergency_contact_phone"
                        value={candidate.emergency_contact_phone || ''}
                        onChange={handleInputChange}
                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm"
                    />
                </div>
            </div>
        </div>

        <div className="mt-6">
            <p className="text-gray-500">さらにフィールドがここに追加されます...</p>
        </div>

      </div>

      {/* Action Buttons */}
      <div className="flex justify-end gap-4">
        <button type="button" onClick={() => navigate(-1)} className="px-6 py-2 border border-gray-300 rounded-md shadow-sm text-sm font-medium text-gray-700 bg-white hover:bg-gray-50">
          キャンセル
        </button>
        <button type="submit" disabled={loading} className="px-6 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-indigo-600 hover:bg-indigo-700 disabled:bg-indigo-300">
          {loading ? '保存中...' : '保存'}
        </button>
      </div>
    </form>
  );
};

export default CandidateForm;