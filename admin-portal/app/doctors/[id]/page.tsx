'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import { useParams, useRouter } from 'next/navigation'
import Link from 'next/link'
import { ChevronLeft, Check, X, Shield, Mail, Phone, MapPin, Calendar, FileText, Building2, User, Edit3, Lock } from 'lucide-react'

interface DetailedProfile {
    id: string
    first_name: string | null
    last_name: string | null
    email: string | null
    role: string
    verification_status: string
    image_url: string | null
    specialty: string | null
    phone_number: string | null
    gender: string | null
    dob: string | null
    address: string | null
    about: string | null
    about_me: string | null
    experience_years: string | null
    license_number: string | null
    hospital_name: string | null
    country: string | null
    insurance_provider: string | null
    insurance_number: string | null
    created_at: string
    verification_key: string | null
}

export default function DoctorDetailPage() {
    const params = useParams()
    const router = useRouter()
    const [profile, setProfile] = useState<DetailedProfile | null>(null)
    const [loading, setLoading] = useState(true)
    const [updating, setUpdating] = useState(false)
    const supabase = createClient()

    useEffect(() => {
        async function fetchDoctor() {
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', params.id)
                .single()

            if (error) {
                console.error('Error fetching doctor:', error)
            } else {
                setProfile(data)
            }
            setLoading(false)
        }
        fetchDoctor()
    }, [params.id])

    const updateStatus = async (newStatus: string) => {
        if (!profile) return
        setUpdating(true)

        const { error } = await supabase.rpc('admin_update_verification_status', {
            target_user_id: profile.id,
            new_status: newStatus
        })

        if (error) {
            alert('Failed to update status')
        } else {
            setProfile({ ...profile, verification_status: newStatus })
            router.refresh()
        }
        setUpdating(false)
    }

    const [isEditing, setIsEditing] = useState(false)
    const [formData, setFormData] = useState<Partial<DetailedProfile>>({})

    useEffect(() => {
        if (profile) {
            setFormData({
                first_name: profile.first_name,
                last_name: profile.last_name,
                license_number: profile.license_number,
                specialty: profile.specialty,
                experience_years: profile.experience_years,
                hospital_name: profile.hospital_name,
                phone_number: profile.phone_number,
                address: profile.address,
                gender: profile.gender,
                dob: profile.dob,
                about: profile.about,
                country: profile.country,
                insurance_provider: profile.insurance_provider,
                insurance_number: profile.insurance_number,
            })
        }
    }, [profile])


    const handleUpdateProfile = async () => {
        if (!profile) return
        setUpdating(true)

        const { error } = await supabase
            .from('profiles')
            .update({
                first_name: formData.first_name,
                last_name: formData.last_name,
                license_number: formData.license_number,
                specialty: formData.specialty,
                experience_years: formData.experience_years,
                hospital_name: formData.hospital_name,
                phone_number: formData.phone_number,
                address: formData.address,
                gender: formData.gender,
                dob: formData.dob,
                about: formData.about,
                country: formData.country,
                insurance_provider: formData.insurance_provider,
                insurance_number: formData.insurance_number,
            })
            .eq('id', profile.id)

        if (error) {
            alert('Failed to update profile: ' + error.message)
        } else {
            setProfile({ ...profile, ...formData } as DetailedProfile)
            setIsEditing(false)
            router.refresh()
        }
        setUpdating(false)
    }

    if (loading) return (
        <div className="flex h-screen items-center justify-center bg-[var(--color-background-light)]">
            <div className="flex flex-col items-center gap-4">
                <div className="h-10 w-10 animate-spin rounded-full border-4 border-blue-600 border-t-transparent"></div>
                <p className="text-sm font-medium text-gray-500 animate-pulse">Loading Profile...</p>
            </div>
        </div>
    )
    if (!profile) return <div className="flex h-screen items-center justify-center">Doctor not found</div>

    return (
        <div className="min-h-screen bg-[var(--color-background-light)] p-6 sm:p-10 font-sans">
            <div className="mx-auto max-w-5xl">
                <div className="mb-6">
                    <Link href="/doctors" className="group inline-flex items-center text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors">
                        <ChevronLeft className="mr-1 h-4 w-4 transition-transform group-hover:-translate-x-0.5" /> Back to List
                    </Link>
                </div>

                {/* Header Card */}
                <div className="relative overflow-hidden rounded-3xl bg-white shadow-soft ring-1 ring-gray-100">
                    <div className="h-40 bg-gradient-to-r from-blue-600 via-indigo-600 to-purple-600">
                        {/* Abstract Pattern Overlay */}
                        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(circle at 2px 2px, white 1px, transparent 0)', backgroundSize: '24px 24px' }}></div>
                    </div>

                    <div className="relative px-8 pb-8">
                        <div className="-mt-16 sm:flex sm:items-end sm:space-x-6">
                            <div className="flex relative">
                                {profile.image_url ? (
                                    // eslint-disable-next-line @next/next/no-img-element
                                    <img className="h-32 w-32 rounded-2xl object-cover ring-4 ring-white shadow-lg bg-white" src={profile.image_url} alt="" />
                                ) : (
                                    <div className="flex h-32 w-32 items-center justify-center rounded-2xl ring-4 ring-white bg-gradient-to-br from-blue-50 to-indigo-50 text-blue-600 text-3xl font-bold shadow-lg">
                                        {profile.first_name?.[0]?.toUpperCase()}
                                    </div>
                                )}
                                <div className="absolute -bottom-2 -right-2">
                                    <div className={`flex items-center justify-center h-8 w-8 rounded-full ring-2 ring-white ${profile.verification_status === 'verified' ? 'bg-emerald-500' :
                                        profile.verification_status === 'pending' ? 'bg-amber-500' : 'bg-rose-500'
                                        }`}>
                                        {profile.verification_status === 'verified' && <Check className="h-4 w-4 text-white stroke-[3]" />}
                                        {profile.verification_status === 'pending' && <Lock className="h-3.5 w-3.5 text-white" />}
                                        {profile.verification_status === 'rejected' && <X className="h-4 w-4 text-white stroke-[3]" />}
                                    </div>
                                </div>
                            </div>

                            <div className="mt-6 sm:flex-1 sm:min-w-0 sm:flex sm:items-center sm:justify-between sm:space-x-6 sm:pb-2">
                                <div className="sm:hidden md:block min-w-0 flex-1">
                                    <h1 className="text-3xl font-bold text-gray-900 truncate font-display">
                                        Dr. {profile.first_name} {profile.last_name}
                                    </h1>
                                    <div className="flex items-center gap-2 mt-1">
                                        <span className="inline-flex items-center rounded-md bg-blue-50 px-2 py-1 text-xs font-medium text-blue-700 ring-1 ring-inset ring-blue-700/10">
                                            {profile.specialty || 'General Practitioner'}
                                        </span>
                                        <span className="text-sm text-gray-500">• {profile.experience_years ? `${profile.experience_years} Years Exp.` : 'New Doctor'}</span>
                                    </div>
                                </div>
                                <div className="mt-6 flex flex-col justify-stretch space-y-3 sm:flex-row sm:space-y-0 sm:space-x-3">
                                    <button
                                        onClick={() => setIsEditing(true)}
                                        className="inline-flex justify-center items-center rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 shadow-sm ring-1 ring-gray-300 hover:bg-gray-50 transition-all"
                                    >
                                        <Edit3 className="mr-2 h-4 w-4 text-gray-500" />
                                        Edit
                                    </button>

                                    {profile.verification_status !== 'verified' && (
                                        <button
                                            onClick={() => updateStatus('verified')}
                                            disabled={updating}
                                            className="inline-flex justify-center items-center rounded-xl bg-emerald-600 px-4 py-2.5 text-sm font-semibold text-white shadow-sm hover:bg-emerald-500 focus-visible:outline focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-emerald-600 transition-all"
                                        >
                                            <Check className="mr-2 h-4 w-4" /> Approve
                                        </button>
                                    )}
                                    {profile.verification_status !== 'rejected' && (
                                        <button
                                            onClick={() => updateStatus('rejected')}
                                            disabled={updating}
                                            className="inline-flex justify-center items-center rounded-xl bg-white px-4 py-2.5 text-sm font-semibold text-rose-600 shadow-sm ring-1 ring-rose-200 hover:bg-rose-50 transition-all"
                                        >
                                            <X className="mr-2 h-4 w-4" /> Reject
                                        </button>
                                    )}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Details Grid */}
                <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-3">
                    {/* Left Column - Contact Info */}
                    <div className="space-y-6 lg:col-span-1">
                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Contact Info</h3>
                            </div>
                            <div className="px-6 py-5 space-y-5">
                                <div className="flex items-start">
                                    <div className="flex-shrink-0">
                                        <Mail className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Email</p>
                                        <p className="text-gray-500">{profile.email}</p>
                                    </div>
                                </div>
                                <div className="flex items-start">
                                    <div className="flex-shrink-0">
                                        <Phone className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Phone</p>
                                        <p className="text-gray-500">{profile.phone_number || 'No phone provided'}</p>
                                    </div>
                                </div>
                                <div className="flex items-start">
                                    <div className="flex-shrink-0">
                                        <MapPin className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Location</p>
                                        <p className="text-gray-500">{profile.address || 'No address provided'}</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Verification</h3>
                            </div>
                            <div className="px-6 py-5">
                                <div className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-semibold uppercase tracking-wide
                                    ${profile.verification_status === 'verified' ? 'bg-emerald-100 text-emerald-800' :
                                        profile.verification_status === 'pending' ? 'bg-amber-100 text-amber-800' : 'bg-rose-100 text-rose-800'}`}>
                                    {profile.verification_status}
                                </div>
                                <p className="mt-4 text-xs text-gray-400">
                                    Account created on {new Date(profile.created_at).toLocaleDateString()}
                                </p>

                                {profile.verification_key && (
                                    <div className="mt-6 rounded-xl bg-blue-50/50 p-4 ring-1 ring-blue-100">
                                        <h4 className="flex items-center text-sm font-semibold text-blue-900 mb-3">
                                            <Shield className="mr-2 h-4 w-4 text-blue-500" />
                                            Verification Key
                                        </h4>
                                        <div className="group relative">
                                            <code className="block w-full rounded-lg bg-white px-3 py-2.5 text-sm font-mono text-gray-700 shadow-sm ring-1 ring-gray-200">
                                                {profile.verification_key}
                                            </code>
                                            <button
                                                onClick={() => {
                                                    navigator.clipboard.writeText(profile.verification_key!)
                                                    alert('Key copied!')
                                                }}
                                                className="absolute right-2 top-2 rounded-md p-1 text-gray-400 hover:bg-gray-100 hover:text-gray-600 transition-colors"
                                            >
                                                <FileText className="h-4 w-4" />
                                            </button>
                                        </div>
                                        <a
                                            href={`mailto:${profile.email}?subject=Your%20Doctor%20Account%20Approved&body=Hello%20Dr.%20${profile.last_name},%0D%0A%0D%0ACongratulations!%20Your%20application%20has%20been%20approved.%0D%0A%0D%0APlease%20use%20the%20following%20verification%20code%20to%20complete%20your%20setup%20in%20the%20app:%0D%0A%0D%0A${profile.verification_key}%0D%0A%0D%0AThank%20you,%0D%0AClinic%20Admin`}
                                            className="mt-4 flex w-full items-center justify-center rounded-lg bg-blue-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-blue-500 transition-colors"
                                        >
                                            <Mail className="mr-2 h-4 w-4" />
                                            Send Key via Email
                                        </a>
                                    </div>
                                )}
                            </div>
                        </div>
                    </div>

                    {/* Right Column - Professional Details */}
                    <div className="lg:col-span-2 space-y-6">
                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Professional Profile</h3>
                            </div>
                            <div className="px-6 py-6">
                                <dl className="grid grid-cols-1 gap-x-6 gap-y-8 sm:grid-cols-2">
                                    <div className="sm:col-span-1">
                                        <dt className="text-sm font-medium text-gray-500">License Number</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900">{profile.license_number || 'N/A'}</dd>
                                    </div>
                                    <div className="sm:col-span-1">
                                        <dt className="text-sm font-medium text-gray-500">Experience</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900">{profile.experience_years ? `${profile.experience_years} Years` : 'Not specified'}</dd>
                                    </div>
                                    <div className="sm:col-span-1">
                                        <dt className="text-sm font-medium text-gray-500">Associated Hospital</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900 flex items-center">
                                            <Building2 className="mr-2 h-4 w-4 text-gray-400" />
                                            {profile.hospital_name || 'Independent / None'}
                                        </dd>
                                    </div>
                                    <div className="sm:col-span-1">
                                        <dt className="text-sm font-medium text-gray-500">Gender</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900 capitalize">{profile.gender || 'Not specified'}</dd>
                                    </div>
                                    <div className="sm:col-span-1">
                                        <dt className="text-sm font-medium text-gray-500">Country</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900">{profile.country || 'Not specified'}</dd>
                                    </div>
                                    <div className="sm:col-span-2">
                                        <dt className="text-sm font-medium text-gray-500">Insurance Info (Optional)</dt>
                                        <dd className="mt-1 text-base font-semibold text-gray-900">
                                            {profile.insurance_provider && profile.insurance_provider !== 'None'
                                                ? `${profile.insurance_provider} - ID: ${profile.insurance_number || 'N/A'}`
                                                : 'No insurance provided'}
                                        </dd>
                                    </div>
                                    <div className="sm:col-span-2">
                                        <dt className="text-sm font-medium text-gray-500">About Doctor</dt>
                                        <dd className="mt-2 text-sm text-gray-700 leading-relaxed bg-gray-50 p-4 rounded-xl border border-gray-100">
                                            {profile.about || profile.about_me || 'No biography provided.'}
                                        </dd>
                                    </div>
                                </dl>
                            </div>
                        </div>

                        {/* Documents Section */}
                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50 flex justify-between items-center">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Uploaded Documents</h3>
                                <span className="inline-flex items-center rounded-md bg-gray-100 px-2 py-1 text-xs font-medium text-gray-600 ring-1 ring-inset ring-gray-500/10">Read-Only</span>
                            </div>
                            <div className="px-6 py-12 text-center">
                                <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-gray-50 mb-3">
                                    <FileText className="h-6 w-6 text-gray-400" />
                                </div>
                                <h3 className="text-sm font-semibold text-gray-900">No documents found</h3>
                                <p className="mt-1 text-sm text-gray-500">This user has not uploaded any verification documents yet.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            {/* Edit Profile Modal */}
            {isEditing && (
                <div className="fixed inset-0 z-50 overflow-y-auto" aria-labelledby="modal-title" role="dialog" aria-modal="true">
                    <div className="flex items-end justify-center min-h-screen pt-4 px-4 pb-20 text-center sm:block sm:p-0">
                        {/* Background overlay */}
                        <div className="fixed inset-0 bg-gray-900/50 backdrop-blur-sm transition-opacity" aria-hidden="true" onClick={() => setIsEditing(false)}></div>

                        {/* Modal panel */}
                        <span className="hidden sm:inline-block sm:align-middle sm:h-screen" aria-hidden="true">&#8203;</span>
                        <div className="inline-block align-bottom bg-white rounded-2xl text-left overflow-hidden shadow-xl transform transition-all sm:my-8 sm:align-middle sm:max-w-lg sm:w-full">
                            <div className="bg-white px-4 pt-5 pb-4 sm:p-6 sm:pb-4">
                                <div className="sm:flex sm:items-start">
                                    <div className="mt-3 text-center sm:mt-0 sm:ml-2 sm:text-left w-full">
                                        <h3 className="text-lg leading-6 font-bold text-gray-900 font-display" id="modal-title">
                                            Edit Doctor Profile
                                        </h3>
                                        <p className="text-sm text-gray-500 mt-1">Update professional details for Dr. {profile.last_name}</p>

                                        <div className="mt-6 space-y-4">
                                            <div className="grid grid-cols-2 gap-4">
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">First Name</label>
                                                    <input
                                                        type="text"
                                                        value={formData.first_name || ''}
                                                        onChange={(e) => setFormData({ ...formData, first_name: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Last Name</label>
                                                    <input
                                                        type="text"
                                                        value={formData.last_name || ''}
                                                        onChange={(e) => setFormData({ ...formData, last_name: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                            </div>
                                            <div>
                                                <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Medical License</label>
                                                <input
                                                    type="text"
                                                    value={formData.license_number || ''}
                                                    onChange={(e) => setFormData({ ...formData, license_number: e.target.value })}
                                                    className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                />
                                            </div>
                                            <div>
                                                <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Specialty</label>
                                                <input
                                                    type="text"
                                                    value={formData.specialty || ''}
                                                    onChange={(e) => setFormData({ ...formData, specialty: e.target.value })}
                                                    className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                />
                                            </div>
                                            <div className="grid grid-cols-2 gap-4">
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Experience (Yrs)</label>
                                                    <input
                                                        type="text"
                                                        value={formData.experience_years || ''}
                                                        onChange={(e) => setFormData({ ...formData, experience_years: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Hospital</label>
                                                    <input
                                                        type="text"
                                                        value={formData.hospital_name || ''}
                                                        onChange={(e) => setFormData({ ...formData, hospital_name: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                            </div>
                                            <div className="grid grid-cols-2 gap-4">
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Phone Number</label>
                                                    <input
                                                        type="text"
                                                        value={formData.phone_number || ''}
                                                        onChange={(e) => setFormData({ ...formData, phone_number: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Location / Address</label>
                                                    <input
                                                        type="text"
                                                        value={formData.address || ''}
                                                        onChange={(e) => setFormData({ ...formData, address: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                            </div>
                                            <div className="grid grid-cols-2 gap-4">
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Gender</label>
                                                    <select
                                                        value={formData.gender || ''}
                                                        onChange={(e) => setFormData({ ...formData, gender: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    >
                                                        <option value="">Select Gender</option>
                                                        <option value="Male">Male</option>
                                                        <option value="Female">Female</option>
                                                        <option value="Other">Other</option>
                                                    </select>
                                                </div>
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Date of Birth</label>
                                                    <input
                                                        type="text"
                                                        placeholder="e.g. 1990-01-01"
                                                        value={formData.dob || ''}
                                                        onChange={(e) => setFormData({ ...formData, dob: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                            </div>
                                            <div className="grid grid-cols-2 gap-4">
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Country</label>
                                                    <select
                                                        value={formData.country || ''}
                                                        onChange={(e) => setFormData({ ...formData, country: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    >
                                                        <option value="">Select Country</option>
                                                        <option value="Rwanda">Rwanda</option>
                                                        <option value="Burundi">Burundi</option>
                                                        <option value="Kenya">Kenya</option>
                                                        <option value="Uganda">Uganda</option>
                                                        <option value="Tanzania">Tanzania</option>
                                                        <option value="USA">USA</option>
                                                        <option value="UK">UK</option>
                                                        <option value="Canada">Canada</option>
                                                        <option value="Other">Other</option>
                                                    </select>
                                                </div>
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Insurance Provider</label>
                                                    <select
                                                        value={formData.insurance_provider || 'None'}
                                                        onChange={(e) => setFormData({ ...formData, insurance_provider: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    >
                                                        <option value="None">None</option>
                                                        <option value="RSSB">RSSB</option>
                                                        <option value="Radiant">Radiant</option>
                                                        <option value="Mutuel">Mutuel</option>
                                                    </select>
                                                </div>
                                            </div>
                                            {formData.insurance_provider && formData.insurance_provider !== 'None' && (
                                                <div>
                                                    <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">Insurance Number / ID</label>
                                                    <input
                                                        type="text"
                                                        value={formData.insurance_number || ''}
                                                        onChange={(e) => setFormData({ ...formData, insurance_number: e.target.value })}
                                                        className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                    />
                                                </div>
                                            )}
                                            <div>
                                                <label className="block text-xs font-medium text-gray-700 uppercase tracking-wide mb-1">About / Bio</label>
                                                <textarea
                                                    rows={3}
                                                    value={formData.about || ''}
                                                    onChange={(e) => setFormData({ ...formData, about: e.target.value })}
                                                    className="block w-full rounded-lg border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 sm:text-sm py-2 px-3 border"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div className="bg-gray-50 px-4 py-3 sm:px-6 sm:flex sm:flex-row-reverse">
                                <button
                                    type="button"
                                    className="w-full inline-flex justify-center rounded-xl border border-transparent shadow-sm px-4 py-2 bg-blue-600 text-base font-medium text-white hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:ml-3 sm:w-auto sm:text-sm"
                                    onClick={handleUpdateProfile}
                                    disabled={updating}
                                >
                                    {updating ? 'Saving...' : 'Save Changes'}
                                </button>
                                <button
                                    type="button"
                                    className="mt-3 w-full inline-flex justify-center rounded-xl border border-gray-300 shadow-sm px-4 py-2 bg-white text-base font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 sm:mt-0 sm:ml-3 sm:w-auto sm:text-sm"
                                    onClick={() => setIsEditing(false)}
                                    disabled={updating}
                                >
                                    Cancel
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            )}
        </div>
    )
}
