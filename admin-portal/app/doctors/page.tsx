'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import Link from 'next/link'
import { ChevronLeft, Check, X, Search, Loader2, UserCheck, ShieldAlert, Award, Filter, ArrowUpRight } from 'lucide-react'

// Define the shape of our doctor profile
interface DoctorProfile {
    id: string
    first_name: string | null
    last_name: string | null
    email: string | null
    role: string
    verification_status: string
    image_url: string | null
    specialty: string | null
    hospital: string | null // If available in future
}

export default function DoctorsPage() {
    const [doctors, setDoctors] = useState<DoctorProfile[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')
    const [statusFilter, setStatusFilter] = useState<'all' | 'pending' | 'verified'>('all')
    const [updatingId, setUpdatingId] = useState<string | null>(null)

    const supabase = createClient()

    useEffect(() => {
        fetchDoctors()
    }, [])

    const fetchDoctors = async () => {
        setLoading(true)
        // Fetch all profiles where role is doctor OR they have an entry in doctors table
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .or('role.eq.doctor,role.eq.admin') // Include admins who might be testing doctor features
            .order('created_at', { ascending: false })

        if (error) {
            console.error('Error fetching doctors:', error)
        } else {
            setDoctors(data as DoctorProfile[] || [])
        }
        setLoading(false)
    }

    const updateStatus = async (id: string, newStatus: string) => {
        setUpdatingId(id)

        // Call the RPC function we created to bypass RLS issues securely
        const { error } = await supabase.rpc('admin_update_verification_status', {
            target_user_id: id,
            new_status: newStatus
        })

        if (error) {
            console.error('Error updating status:', error)
            alert(`Failed to update status: ${error.message}`)
        } else {
            // Optimistic update
            setDoctors(doctors.map(doc =>
                doc.id === id ? { ...doc, verification_status: newStatus } : doc
            ))
        }

        setUpdatingId(null)
    }

    const filteredDoctors = doctors.filter(doc => {
        const fullName = `${doc.first_name || ''} ${doc.last_name || ''}`.toLowerCase()
        const email = (doc.email || '').toLowerCase()
        const term = searchTerm.toLowerCase()
        const matchesSearch = fullName.includes(term) || email.includes(term)
        const matchesFilter = statusFilter === 'all' || doc.verification_status === statusFilter

        return matchesSearch && matchesFilter
    })

    // Stats for the header
    const pendingCount = doctors.filter(d => d.verification_status === 'pending').length
    const verifiedCount = doctors.filter(d => d.verification_status === 'verified').length

    // Status Badge Component
    const StatusBadge = ({ status }: { status: string }) => {
        let styles = 'bg-gray-100 text-gray-600 ring-gray-500/10'
        if (status === 'verified') styles = 'bg-emerald-50 text-emerald-700 ring-emerald-600/20'
        if (status === 'pending') styles = 'bg-amber-50 text-amber-700 ring-amber-600/20'
        if (status === 'rejected') styles = 'bg-rose-50 text-rose-700 ring-rose-600/10'

        return (
            <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ring-1 ring-inset ${styles}`}>
                {status ? status.charAt(0).toUpperCase() + status.slice(1) : 'Unknown'}
            </span>
        )
    }

    return (
        <div className="min-h-screen bg-[var(--color-background-light)] p-6 sm:p-10 font-sans">
            <div className="mx-auto max-w-7xl">

                {/* Header */}
                <div className="mb-10 flex flex-col gap-6 sm:flex-row sm:items-center sm:justify-between">
                    <div className="flex items-center gap-4">
                        <Link href="/" className="group flex h-10 w-10 items-center justify-center rounded-xl bg-white shadow-sm ring-1 ring-gray-200 transition-all hover:ring-blue-200 hover:text-blue-600 hover:shadow-md">
                            <ChevronLeft className="h-5 w-5 transition-transform group-hover:-translate-x-0.5" />
                        </Link>
                        <div>
                            <h1 className="text-3xl font-bold tracking-tight text-gray-900 font-display">Medical Staff</h1>
                            <p className="mt-1.5 text-sm text-gray-500">Manage verification and profiles for {doctors.length} doctors</p>
                        </div>
                    </div>

                    <div className="flex gap-4">
                        <div className="flex items-center gap-3 rounded-2xl bg-white p-1 pl-2 pr-4 shadow-sm ring-1 ring-gray-100">
                            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-amber-50">
                                <ShieldAlert className="h-5 w-5 text-amber-600" />
                            </div>
                            <div>
                                <p className="text-xs font-medium text-gray-500">Pending</p>
                                <p className="text-lg font-bold text-gray-900 leading-none">{pendingCount}</p>
                            </div>
                        </div>
                        <div className="flex items-center gap-3 rounded-2xl bg-white p-1 pl-2 pr-4 shadow-sm ring-1 ring-gray-100">
                            <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-emerald-50">
                                <Award className="h-5 w-5 text-emerald-600" />
                            </div>
                            <div>
                                <p className="text-xs font-medium text-gray-500">Verified</p>
                                <p className="text-lg font-bold text-gray-900 leading-none">{verifiedCount}</p>
                            </div>
                        </div>
                    </div>
                </div>

                {/* Filters & Search */}
                <div className="mb-8 flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between bg-white p-2 rounded-2xl shadow-sm ring-1 ring-gray-100">
                    <div className="relative max-w-md flex-1">
                        <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3">
                            <Search className="h-4 w-4 text-gray-400" />
                        </div>
                        <input
                            type="text"
                            placeholder="Search by name or email..."
                            className="block w-full rounded-xl border-0 py-2.5 pl-9 pr-4 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 bg-transparent"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
                    </div>

                    <div className="flex gap-1 bg-gray-50/80 p-1 rounded-xl">
                        {(['all', 'pending', 'verified'] as const).map((filter) => (
                            <button
                                key={filter}
                                onClick={() => setStatusFilter(filter)}
                                className={`rounded-lg px-3 py-1.5 text-sm font-medium transition-all duration-200 ${statusFilter === filter
                                    ? 'bg-white text-gray-900 shadow-sm ring-1 ring-black/5'
                                    : 'text-gray-500 hover:text-gray-700 hover:bg-gray-100'
                                    }`}
                            >
                                {filter.charAt(0).toUpperCase() + filter.slice(1)}
                            </button>
                        ))}
                    </div>
                </div>

                {/* Table */}
                <div className="overflow-hidden rounded-2xl bg-white shadow-sm ring-1 ring-gray-200">
                    {loading ? (
                        <div className="flex h-96 items-center justify-center flex-col gap-4">
                            <div className="relative">
                                <div className="h-12 w-12 rounded-full border-4 border-gray-100"></div>
                                <div className="absolute top-0 left-0 h-12 w-12 animate-spin rounded-full border-4 border-blue-600 border-t-transparent"></div>
                            </div>
                            <p className="text-sm font-medium text-gray-500 animate-pulse">Loading profiles...</p>
                        </div>
                    ) : (
                        <table className="min-w-full divide-y divide-gray-100">
                            <thead>
                                <tr className="bg-gray-50/50">
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500 pl-8">
                                        Doctor Profile
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                        Specialty
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                        Status
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-right text-xs font-semibold uppercase tracking-wider text-gray-500 pr-8">
                                        Actions
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100 bg-white">
                                {filteredDoctors.length === 0 ? (
                                    <tr>
                                        <td colSpan={4} className="px-6 py-24 text-center">
                                            <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gray-50 mb-4">
                                                <UserCheck className="h-8 w-8 text-gray-400" />
                                            </div>
                                            <h3 className="text-base font-semibold text-gray-900">No doctors found</h3>
                                            <p className="mt-1 text-sm text-gray-500 max-w-sm mx-auto">
                                                We couldn't find any doctors matching your search filters. Try adjusting your terms.
                                            </p>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredDoctors.map((doc) => (
                                        <tr key={doc.id} className="group hover:bg-gray-50/80 transition-colors duration-200">
                                            <td className="whitespace-nowrap px-6 py-5 pl-8">
                                                <Link href={`/doctors/${doc.id}`} className="flex items-center">
                                                    <div className="h-11 w-11 flex-shrink-0 relative">
                                                        {doc.image_url ? (
                                                            // eslint-disable-next-line @next/next/no-img-element
                                                            <img className="h-11 w-11 rounded-full object-cover ring-2 ring-white shadow-sm" src={doc.image_url} alt="" />
                                                        ) : (
                                                            <div className="flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br from-blue-50 to-indigo-50 text-blue-600 font-bold ring-2 ring-white shadow-sm">
                                                                {doc.first_name?.[0]?.toUpperCase() || 'D'}
                                                            </div>
                                                        )}
                                                        {doc.verification_status === 'verified' && (
                                                            <div className="absolute -bottom-0.5 -right-0.5 rounded-full bg-white p-0.5">
                                                                <div className="rounded-full bg-emerald-500 p-1">
                                                                    <Check className="h-2 w-2 text-white stroke-[3]" />
                                                                </div>
                                                            </div>
                                                        )}
                                                    </div>
                                                    <div className="ml-4">
                                                        <div className="flex items-center gap-2">
                                                            <span className="text-sm font-semibold text-gray-900 group-hover:text-blue-600 transition-colors">
                                                                {doc.first_name ? `Dr. ${doc.first_name} ${doc.last_name}` : 'Unknown Doctor'}
                                                            </span>
                                                            {(doc as any).verification_key && (
                                                                <span className="bg-blue-50 text-blue-600 text-[10px] font-mono px-1.5 py-0.5 rounded border border-blue-100">
                                                                    Key: {(doc as any).verification_key}
                                                                </span>
                                                            )}
                                                        </div>
                                                        <div className="text-xs text-gray-500 font-medium">{doc.email}</div>
                                                    </div>
                                                </Link>
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5">
                                                <div className="flex items-center gap-1.5">
                                                    <div className="h-1.5 w-1.5 rounded-full bg-blue-500"></div>
                                                    <span className="text-sm text-gray-700 font-medium">{doc.specialty || 'General Physician'}</span>
                                                </div>
                                                <div className="text-xs text-gray-400 pl-3">Board Certified</div>
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5">
                                                <StatusBadge status={doc.verification_status || 'pending'} />
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5 text-right text-sm font-medium pr-8">
                                                <div className="flex justify-end items-center gap-2 opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                                                    <Link href={`/doctors/${doc.id}`} className="inline-flex items-center justify-center rounded-lg bg-white px-3 py-1.5 text-xs font-medium text-gray-600 shadow-sm ring-1 ring-gray-200 hover:bg-gray-50 hover:text-gray-900 transition-all">
                                                        View
                                                        <ArrowUpRight className="ml-1.5 h-3 w-3 text-gray-400" />
                                                    </Link>
                                                    {doc.verification_status !== 'verified' && (
                                                        <button
                                                            onClick={(e) => {
                                                                e.stopPropagation();
                                                                updateStatus(doc.id, 'verified');
                                                            }}
                                                            disabled={updatingId === doc.id}
                                                            className="inline-flex items-center justify-center rounded-lg bg-emerald-50 px-3 py-1.5 text-xs font-medium text-emerald-700 hover:bg-emerald-100 ring-1 ring-emerald-600/10 transition-colors"
                                                        >
                                                            {updatingId === doc.id ? (
                                                                <Loader2 className="h-3 w-3 animate-spin mr-1.5" />
                                                            ) : (
                                                                <Check className="mr-1.5 h-3 w-3" />
                                                            )}
                                                            Approve
                                                        </button>
                                                    )}

                                                    {doc.verification_status !== 'rejected' && (
                                                        <button
                                                            onClick={(e) => {
                                                                e.stopPropagation()
                                                                updateStatus(doc.id, 'rejected')
                                                            }}
                                                            disabled={updatingId === doc.id}
                                                            className="inline-flex h-8 w-8 items-center justify-center rounded-lg bg-white text-gray-400 hover:bg-rose-50 hover:text-rose-600 ring-1 ring-gray-200 hover:ring-rose-200 transition-all"
                                                            title="Reject Application"
                                                        >
                                                            <X className="h-4 w-4" />
                                                        </button>
                                                    )}
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    )}
                </div>
            </div>
        </div>
    )
}
