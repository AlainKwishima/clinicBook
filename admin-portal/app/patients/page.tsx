'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/utils/supabase/client'
import Link from 'next/link'
import { ChevronLeft, Search, Loader2, User, Eye, Users, Calendar, ArrowUpRight } from 'lucide-react'

interface PatientProfile {
    id: string
    first_name: string | null
    last_name: string | null
    email: string | null
    phone_number: string | null
    gender: string | null
    created_at: string
}

export default function PatientsPage() {
    const [patients, setPatients] = useState<PatientProfile[]>([])
    const [loading, setLoading] = useState(true)
    const [searchTerm, setSearchTerm] = useState('')

    const supabase = createClient()

    useEffect(() => {
        fetchPatients()
    }, [])

    const fetchPatients = async () => {
        setLoading(true)
        const { data, error } = await supabase
            .from('profiles')
            .select('*')
            .eq('role', 'patient')
            .order('created_at', { ascending: false })
            .limit(50) // Limit for performance initially

        if (error) {
            console.error('Error fetching patients:', error)
        } else {
            setPatients(data as PatientProfile[] || [])
        }
        setLoading(false)
    }

    const filteredPatients = patients.filter(p => {
        const fullName = `${p.first_name || ''} ${p.last_name || ''}`.toLowerCase()
        const email = (p.email || '').toLowerCase()
        const term = searchTerm.toLowerCase()
        return fullName.includes(term) || email.includes(term)
    })

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
                            <h1 className="text-3xl font-bold tracking-tight text-gray-900 font-display">Patient Directory</h1>
                            <p className="mt-1.5 text-sm text-gray-500">View and manage {patients.length} registered patients</p>
                        </div>
                    </div>

                    <div className="flex items-center gap-3 rounded-2xl bg-white p-1 pl-2 pr-4 shadow-sm ring-1 ring-gray-100">
                        <div className="flex h-10 w-10 items-center justify-center rounded-xl bg-blue-50">
                            <Users className="h-5 w-5 text-blue-600" />
                        </div>
                        <div>
                            <p className="text-xs font-medium text-gray-500">Total Patients</p>
                            <p className="text-lg font-bold text-gray-900 leading-none">{patients.length}</p>
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
                            placeholder="Search patients..."
                            className="block w-full rounded-xl border-0 py-2.5 pl-9 pr-4 text-gray-900 placeholder:text-gray-400 focus:ring-2 focus:ring-inset focus:ring-blue-600 sm:text-sm sm:leading-6 bg-transparent"
                            value={searchTerm}
                            onChange={(e) => setSearchTerm(e.target.value)}
                        />
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
                            <p className="text-sm font-medium text-gray-500 animate-pulse">Loading directory...</p>
                        </div>
                    ) : (
                        <table className="min-w-full divide-y divide-gray-100">
                            <thead>
                                <tr className="bg-gray-50/50">
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500 pl-8">
                                        Patient Name
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                        Contacts
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-left text-xs font-semibold uppercase tracking-wider text-gray-500">
                                        Joined Date
                                    </th>
                                    <th scope="col" className="px-6 py-5 text-right text-xs font-semibold uppercase tracking-wider text-gray-500 pr-8">
                                        Actions
                                    </th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-gray-100 bg-white">
                                {filteredPatients.length === 0 ? (
                                    <tr>
                                        <td colSpan={4} className="px-6 py-24 text-center">
                                            <div className="mx-auto flex h-16 w-16 items-center justify-center rounded-full bg-gray-50 mb-4">
                                                <User className="h-8 w-8 text-gray-400" />
                                            </div>
                                            <h3 className="text-base font-semibold text-gray-900">No patients found</h3>
                                            <p className="mt-1 text-sm text-gray-500 max-w-sm mx-auto">
                                                We couldn't find any patients matching your search.
                                            </p>
                                        </td>
                                    </tr>
                                ) : (
                                    filteredPatients.map((patient) => (
                                        <tr key={patient.id} className="group hover:bg-gray-50/80 transition-colors duration-200">
                                            <td className="whitespace-nowrap px-6 py-5 pl-8">
                                                <Link href={`/patients/${patient.id}`} className="flex items-center">
                                                    <div className="h-11 w-11 flex-shrink-0">
                                                        <div className="flex h-11 w-11 items-center justify-center rounded-full bg-gradient-to-br from-purple-50 to-pink-50 text-purple-600 font-bold ring-2 ring-white shadow-sm">
                                                            {patient.first_name?.[0]?.toUpperCase() || 'P'}
                                                        </div>
                                                    </div>
                                                    <div className="ml-4">
                                                        <div className="text-sm font-semibold text-gray-900 group-hover:text-purple-600 transition-colors">
                                                            {patient.first_name} {patient.last_name}
                                                        </div>
                                                        <div className="text-xs text-gray-500 capitalize">{patient.gender || 'Unknown gender'}</div>
                                                    </div>
                                                </Link>
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5">
                                                <div className="text-sm text-gray-900">{patient.email}</div>
                                                <div className="text-xs text-gray-500">{patient.phone_number || 'No phone'}</div>
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5">
                                                <div className="flex items-center text-sm text-gray-500">
                                                    <Calendar className="mr-1.5 h-3.5 w-3.5 text-gray-400" />
                                                    {new Date(patient.created_at).toLocaleDateString()}
                                                </div>
                                            </td>
                                            <td className="whitespace-nowrap px-6 py-5 text-right text-sm font-medium pr-8">
                                                <div className="flex justify-end opacity-100 sm:opacity-0 sm:group-hover:opacity-100 transition-opacity">
                                                    <Link href={`/patients/${patient.id}`} className="inline-flex items-center justify-center rounded-lg bg-white px-3 py-1.5 text-xs font-medium text-gray-600 shadow-sm ring-1 ring-gray-200 hover:bg-purple-50 hover:text-purple-700 hover:ring-purple-200 transition-all">
                                                        View Profile
                                                        <ArrowUpRight className="ml-1.5 h-3 w-3" />
                                                    </Link>
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
