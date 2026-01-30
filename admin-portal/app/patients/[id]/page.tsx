'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import { useParams } from 'next/navigation'
import Link from 'next/link'
import { ChevronLeft, User, Mail, Phone, MapPin, Calendar, Heart, Shield, Activity, Weight, Ruler } from 'lucide-react'

interface DetailedPatient {
    id: string
    first_name: string | null
    last_name: string | null
    email: string | null
    role: string
    phone_number: string | null
    gender: string | null
    dob: string | null
    blood_group: string | null
    weight: string | null
    height: string | null
    age: string | null
    address: string | null
    country: string | null
    insurance_provider: string | null
    insurance_number: string | null
    created_at: string
}

export default function PatientDetailPage() {
    const params = useParams()
    const [profile, setProfile] = useState<DetailedPatient | null>(null)
    const [loading, setLoading] = useState(true)
    const supabase = createClient()

    useEffect(() => {
        async function fetchPatient() {
            const { data, error } = await supabase
                .from('profiles')
                .select('*')
                .eq('id', params.id)
                .single()

            if (error) {
                console.error('Error fetching patient:', error)
            } else {
                setProfile(data)
            }
            setLoading(false)
        }
        fetchPatient()
    }, [params.id])

    if (loading) return (
        <div className="flex h-screen items-center justify-center bg-[var(--color-background-light)]">
            <div className="flex flex-col items-center gap-4">
                <div className="h-10 w-10 animate-spin rounded-full border-4 border-purple-600 border-t-transparent"></div>
                <p className="text-sm font-medium text-gray-500 animate-pulse">Loading Patient Profile...</p>
            </div>
        </div>
    )
    if (!profile) return <div className="flex h-screen items-center justify-center">Patient not found</div>

    return (
        <div className="min-h-screen bg-[var(--color-background-light)] p-6 sm:p-10 font-sans">
            <div className="mx-auto max-w-5xl">
                <div className="mb-6">
                    <Link href="/patients" className="group inline-flex items-center text-sm font-medium text-gray-500 hover:text-gray-900 transition-colors">
                        <ChevronLeft className="mr-1 h-4 w-4 transition-transform group-hover:-translate-x-0.5" /> Back to Directory
                    </Link>
                </div>

                {/* Header Card */}
                <div className="relative overflow-hidden rounded-3xl bg-white shadow-soft ring-1 ring-gray-100">
                    <div className="h-40 bg-gradient-to-r from-purple-600 via-fuchsia-600 to-pink-600">
                        {/* Abstract Pattern Overlay */}
                        <div className="absolute inset-0 opacity-10" style={{ backgroundImage: 'radial-gradient(circle at 2px 2px, white 1px, transparent 0)', backgroundSize: '24px 24px' }}></div>
                    </div>
                    <div className="relative px-8 pb-8">
                        <div className="-mt-16 sm:flex sm:items-end sm:space-x-6">
                            <div className="flex">
                                <div className="flex h-32 w-32 items-center justify-center rounded-2xl ring-4 ring-white bg-gradient-to-br from-purple-50 to-pink-50 text-purple-600 text-4xl font-bold shadow-lg">
                                    {profile.first_name?.[0]?.toUpperCase()}
                                </div>
                            </div>
                            <div className="mt-6 sm:flex-1 sm:min-w-0 sm:flex sm:items-center sm:justify-between sm:space-x-6 sm:pb-2">
                                <div className="sm:hidden md:block min-w-0 flex-1">
                                    <h1 className="text-3xl font-bold text-gray-900 truncate font-display">
                                        {profile.first_name} {profile.last_name}
                                    </h1>
                                    <div className="flex items-center gap-2 mt-1">
                                        <span className="inline-flex items-center rounded-md bg-purple-50 px-2 py-1 text-xs font-medium text-purple-700 ring-1 ring-inset ring-purple-700/10">
                                            Patient
                                        </span>
                                        <span className="text-sm text-gray-500">• Member since {new Date(profile.created_at).getFullYear()}</span>
                                    </div>
                                </div>
                                <div className="mt-6 flex flex-col justify-stretch space-y-3 sm:flex-row sm:space-y-0 sm:space-x-4">
                                    <button
                                        className="inline-flex justify-center items-center rounded-xl border border-gray-300 bg-white px-4 py-2.5 text-sm font-semibold text-gray-700 shadow-sm hover:bg-gray-50 cursor-not-allowed opacity-60"
                                        disabled
                                    >
                                        <Shield className="mr-2 h-4 w-4 text-gray-400" /> Manage Account
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Details Grid */}
                <div className="mt-8 grid grid-cols-1 gap-6 lg:grid-cols-2">
                    {/* Left Column - Contact Info */}
                    <div className="space-y-6">
                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Personal Information</h3>
                            </div>
                            <div className="px-6 py-5 space-y-5">
                                <div className="grid grid-cols-2 gap-6">
                                    <div>
                                        <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Date of Birth</p>
                                        <div className="mt-1 flex items-center text-sm font-medium text-gray-900">
                                            <Calendar className="mr-2 h-4 w-4 text-gray-400" />
                                            {profile.dob || 'Not provided'}
                                        </div>
                                    </div>
                                    <div>
                                        <p className="text-xs font-medium text-gray-500 uppercase tracking-wide">Gender</p>
                                        <p className="mt-1 text-sm font-medium text-gray-900 capitalize">{profile.gender || 'Not specified'}</p>
                                    </div>
                                </div>
                                <hr className="border-gray-100" />
                                <div className="flex items-start">
                                    <div className="flex-shrink-0 mt-0.5">
                                        <Mail className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Email Address</p>
                                        <p className="text-gray-500">{profile.email}</p>
                                    </div>
                                </div>
                                <div className="flex items-start">
                                    <div className="flex-shrink-0 mt-0.5">
                                        <Phone className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Phone Number</p>
                                        <p className="text-gray-500">{profile.phone_number || 'No phone provided'}</p>
                                    </div>
                                </div>
                                <div className="flex items-start">
                                    <div className="flex-shrink-0 mt-0.5">
                                        <MapPin className="h-5 w-5 text-gray-400" />
                                    </div>
                                    <div className="ml-3 text-sm flex-1">
                                        <p className="font-medium text-gray-900">Location & Country</p>
                                        <p className="text-gray-500">{profile.address || 'No address'}{profile.country ? `, ${profile.country}` : ''}</p>
                                    </div>
                                </div>
                                <hr className="border-gray-100" />
                                <div className="flex items-start">
                                    <div className="flex-shrink-0 mt-0.5">
                                        <Shield className="h-5 w-5 text-purple-400" />
                                    </div>
                                    <div className="ml-3 text-sm">
                                        <p className="font-medium text-gray-900">Insurance (Rwanda)</p>
                                        <p className="text-gray-500">
                                            {profile.insurance_provider && profile.insurance_provider !== 'None'
                                                ? `${profile.insurance_provider} - ID: ${profile.insurance_number || 'N/A'}`
                                                : 'No insurance provided'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>

                    {/* Right Column - Health Details */}
                    <div className="space-y-6">
                        <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-100">
                            <div className="px-6 py-4 border-b border-gray-100 bg-gray-50/50">
                                <h3 className="text-sm font-semibold leading-6 text-gray-900 uppercase tracking-wider">Health Profile</h3>
                            </div>
                            <div className="p-6">
                                <div className="grid grid-cols-1 gap-4 sm:grid-cols-2 md:grid-cols-4">
                                    {/* Blood Group Card */}
                                    <div className="rounded-xl bg-rose-50 p-4 ring-1 ring-rose-100 text-center">
                                        <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-rose-100 mb-2">
                                            <Heart className="h-5 w-5 text-rose-500" />
                                        </div>
                                        <dt className="text-xs font-medium text-rose-600 uppercase tracking-wide">Blood Group</dt>
                                        <dd className="mt-1 text-xl font-bold text-gray-900">{profile.blood_group || '-'}</dd>
                                    </div>

                                    {/* Height Card */}
                                    <div className="rounded-xl bg-blue-50 p-4 ring-1 ring-blue-100 text-center">
                                        <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-blue-100 mb-2">
                                            <Ruler className="h-5 w-5 text-blue-500" />
                                        </div>
                                        <dt className="text-xs font-medium text-blue-600 uppercase tracking-wide">Height</dt>
                                        <dd className="mt-1 text-xl font-bold text-gray-900">{profile.height ? `${profile.height} cm` : '-'}</dd>
                                    </div>

                                    {/* Weight Card */}
                                    <div className="rounded-xl bg-emerald-50 p-4 ring-1 ring-emerald-100 text-center">
                                        <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-emerald-100 mb-2">
                                            <Weight className="h-5 w-5 text-emerald-500" />
                                        </div>
                                        <dt className="text-xs font-medium text-emerald-600 uppercase tracking-wide">Weight</dt>
                                        <dd className="mt-1 text-xl font-bold text-gray-900">{profile.weight ? `${profile.weight} kg` : '-'}</dd>
                                    </div>

                                    {/* Age Card */}
                                    <div className="rounded-xl bg-purple-50 p-4 ring-1 ring-purple-100 text-center">
                                        <div className="mx-auto flex h-10 w-10 items-center justify-center rounded-full bg-purple-100 mb-2">
                                            <Calendar className="h-5 w-5 text-purple-500" />
                                        </div>
                                        <dt className="text-xs font-medium text-purple-600 uppercase tracking-wide">Age</dt>
                                        <dd className="mt-1 text-xl font-bold text-gray-900">{profile.age || '-'}</dd>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div className="rounded-2xl bg-gradient-to-br from-blue-50 to-indigo-50 p-6 ring-1 ring-blue-100">
                            <div className="flex">
                                <div className="flex-shrink-0">
                                    <Shield className="h-6 w-6 text-blue-600" aria-hidden="true" />
                                </div>
                                <div className="ml-4">
                                    <h3 className="text-base font-semibold text-blue-900">Account Status</h3>
                                    <div className="mt-2 text-sm text-blue-700">
                                        <p>This patient account is active and in good standing. No restrictions are currently applied.</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    )
}
